#import <MPCore.h>
#import <MPBulletPhysicsSubject.h>
#import <MPBulletPhysicsHelpers.h>
#import <MPPhysicalObject.h>
#import <MPGhostObject.h>
#import <MPBulletPhysicsGlobalParams.h>
#import <MPAttractorObject.h>

#import <iostream>
#import <cmath>

using namespace std;

MPPool *dictionaryPool=[[MPPool alloc] initWithClass: [MPMutableDictionary class]];
NSMutableSet *collidedObjectsSet = [NSMutableSet new];
NSMutableDictionary *recentlyCollidedObjects = [NSMutableDictionary new];
NSMutableArray *recentlyCollidedObjectsTimes = [NSMutableArray new];
MPPool *pairPool = [[MPPool alloc] initWithClass: [MPPair class]];

NSUInteger minimalCollisionInterval = 0;

bool CollisionCallback(
				btManifoldPoint& cp,
				const btCollisionObject* colObj0,
				int partId0,
				int index0,
				const btCollisionObject* colObj1,
			    int partId1,
			    int index1)
{
	id<MPObject> obj1 = static_cast<id>(colObj0->getUserPointer());
	id<MPObject> obj2 = static_cast<id>(colObj1->getUserPointer());
	if ([obj1 hasFeature: @"quietcollisions"] || [obj2 hasFeature: @"quietcollisions"])
	{
		return false;
	}

	if (minimalCollisionInterval)
	{
		MPPair *collidedHandlePair = [pairPool newObject];
		[collidedHandlePair setObject1: [obj1 getHandle] object2: [obj2 getHandle]];
		MPUIntWrapper *times;
		times = [recentlyCollidedObjects objectForKey: collidedHandlePair];
		if (!times)
		{
			times = [MPUIntWrapper new];
			[recentlyCollidedObjects setObject: times forKey: collidedHandlePair];
			[recentlyCollidedObjectsTimes addObject: times];
			[times release];
		}
		else
		{
			if ([times getValue] < minimalCollisionInterval)
			{
				[times setValue: 0];
				[collidedHandlePair release];
				return false;
			}
			[times setValue: 0];
		}
		[collidedHandlePair release];
	}
	MPPair *collidedPair = [pairPool newObject];
	[collidedPair setObject1: obj1 object2: obj2];
	[collidedObjectsSet addObject: collidedPair];
	[collidedPair release];
	return false;
}

@interface MPPair (MPBulletPhysicsCollisionMessager)
-(void)postCollisionMessageWithAPI: (id<MPAPI>)api;
@end

@implementation MPPair (MPBulletPhysicsCollisionMessager)
-(void)postCollisionMessageWithAPI: (id<MPAPI>)api
{
	id obj1 = [self getFirstObject];
	id obj2 = [self getSecondObject];
	id dictionary = [dictionaryPool newObject];
	[dictionary setObject: [obj1 getName] forKey: @"object1Name"];
	[dictionary setObject: [obj2 getName] forKey: @"object2Name"];
	[api postMessageWithName: @"objectsCollided" userInfo: dictionary];
	[dictionary release];
}
@end

void tickCallback(btDynamicsWorld *world, btScalar timeStep)
{
	[MPAttractorObject updateWorldWithAPI: (id)(world->getWorldUserInfo()) byTime: timeStep];
}

@implementation MPBulletPhysicsSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	NSDictionary *params = parseParamsString(aParams);

	#define MPBPS_LOADDOUBLEVALUE(nam, def) MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(params, nam, def);
	#define MPBPS_LOADINTVALUE(nam, def) MPBPS_LOAD_INTVALUE_FROMDICTIONARY(params, nam, def); 

	MPBPS_LOADDOUBLEVALUE(minX, -10000);
	MPBPS_LOADDOUBLEVALUE(minY, -10000);
	MPBPS_LOADDOUBLEVALUE(minZ, -10000);
	MPBPS_LOADDOUBLEVALUE(maxX, 10000);
	MPBPS_LOADDOUBLEVALUE(maxY, 10000);
	MPBPS_LOADDOUBLEVALUE(maxZ, 10000);

	MPBPS_LOADDOUBLEVALUE(gravX, 0);
	MPBPS_LOADDOUBLEVALUE(gravY, -9.8);
	MPBPS_LOADDOUBLEVALUE(gravZ, 0);

	MPBPS_LOADINTVALUE(maxObjects, 16384);
	MPBPS_LOADINTVALUE(velocityCleaningOnManualMove, 1);

	#undef MPBPS_LOADDOUBLEVALUE
	#undef MPBPS_LOADINTVALUE

	linearVelocitySleepingThreshold = getDoubleValueFromDictionary(params, @"linearVelocitySleepingThreshold", 0);
	angularVelocitySleepingThreshold = getDoubleValueFromDictionary(params, @"angularVelocitySleepingThreshold", 0);

	timeBalance = getIntValueFromDictionary(params, @"timeBalance", 1);
	maxSubSteps = getIntValueFromDictionary(params, @"maxSubSteps", 1);
	lastTime = getMilliseconds();

	minimalCollisionInterval = getIntValueFromDictionary(params, @"minimalCollisionInterval", 0);

	collisionConfiguration = new btDefaultCollisionConfiguration();
	dispatcher = new btCollisionDispatcher(collisionConfiguration);

	btVector3 worldAabbMin(minX, minY, minZ);
	btVector3 worldAabbMax(maxX, maxY, maxZ);

	if (maxObjects <= 16384)
	{
		overlappingPairCache = new btAxisSweep3(worldAabbMin,worldAabbMax,maxObjects);
	}
	else
	{
		overlappingPairCache = new bt32BitAxisSweep3(worldAabbMin,worldAabbMax,maxObjects);
	}

	overlappingPairCache->getOverlappingPairCache()->setInternalGhostPairCallback(new btGhostPairCallback);
	
	solver = new btSequentialImpulseConstraintSolver;
	dynamicsWorld = new btDiscreteDynamicsWorld(dispatcher,overlappingPairCache,solver,collisionConfiguration);
	dynamicsWorld->setGravity(btVector3(gravX, gravY, gravZ));

	gContactAddedCallback = &CollisionCallback;

	[MPPhysicalObjectDelegate setWorld: dynamicsWorld];
	[MPGhostObjectDelegate setWorld: dynamicsWorld];
	[MPAttractorObject setWorld: dynamicsWorld];
	
	NSString *paramValue;
	if ((paramValue = [params objectForKey: @"2D"]) != nil)
	{
		mode2D = YES;
		if ([paramValue isEqualToString: @"X"])
		{
			disabledAxis = 0;
		}
		if ([paramValue isEqualToString: @"Y"])
		{
			disabledAxis = 1;
		}
		if ([paramValue isEqualToString: @"Z"])
		{
			disabledAxis = 2;
		}
		enabledAxis1 = (disabledAxis + 1) % 3;
		enabledAxis2 = (disabledAxis + 2) % 3;
		if (enabledAxis1 > enabledAxis2)
		{
			swap(enabledAxis1, enabledAxis2);
		}
		zeroBody = new btRigidBody(0, NULL, NULL);
	}

	[MPPhysicalObjectDelegate setCleaningVelocityOnManualMove: velocityCleaningOnManualMove];

	disableObjectDeactivation = getIntValueFromDictionary(params, @"disableObjectDeactivation", 0);
	disableCalculateAttractedObjects = getIntValueFromDictionary(params, @"disableCalculateAttractedObjects", 0);

	return self;
}

- init
{
	return [self initWithString: @""];
}

- (void) dealloc
{
	if (api)
	{
		[api release];
	}

	delete dynamicsWorld;
	delete solver;
	delete overlappingPairCache;
	delete dispatcher;
	delete collisionConfiguration;

	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	api = [anAPI retain];

	[MPPhysicalObjectDelegate setAPI: api];
	dynamicsWorld->setInternalTickCallback(&tickCallback, api);

}

- (void) start
{
	[[api getObjectSystem] registerDelegate: [MPPhysicalObjectDelegate class] forFeature: @"physical"];
	[[api getObjectSystem] registerDelegate: [MPGhostObjectDelegate class] forFeature: @"ghostObject"];
	[[api getObjectSystem] registerDelegate: [MPAttractorObject class] forFeature: @"attractor"];
}

- (void) stop
{
	[[api getObjectSystem] removeDelegate: [MPPhysicalObjectDelegate class] forFeature: @"physical"];
	[[api getObjectSystem] removeDelegate: [MPGhostObjectDelegate class] forFeature: @"ghostObject"];
	[[api getObjectSystem] removeDelegate: [MPAttractorObject class] forFeature: @"attractor"];
	[collidedObjectsSet removeAllObjects];
	[recentlyCollidedObjects removeAllObjects];
	[recentlyCollidedObjectsTimes removeAllObjects];

	[[api log] add: notice withFormat: @"MPBulletPhysicsSubject: %d - pairPool size; %d - dictionaryPool size",
											[pairPool size], [dictionaryPool size]];

	[pairPool purge];
	[dictionaryPool purge];
}

- (void) update
{
	if (timeBalance)
	{
		double now = getMilliseconds();
		[worldLockMutex lock];
		dynamicsWorld->stepSimulation((now-lastTime)/1000.f, maxSubSteps);
		[worldLockMutex unlock];
		lastTime = now;
	}
	else
	{
		dynamicsWorld->stepSimulation(1.f/60, maxSubSteps);
	}
	[collidedObjectsSet makeObjectsPerformSelector: @selector(postCollisionMessageWithAPI:) withObject: api];
	[collidedObjectsSet removeAllObjects];
	if (minimalCollisionInterval)
	{
		NSUInteger i, count = [recentlyCollidedObjectsTimes count];
		for (i=0;i<count;++i)
		{
			[[recentlyCollidedObjectsTimes objectAtIndex: i] inc];
		}
	}
}

MP_HANDLER_OF_MESSAGE(setGravity)
{
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, X, 0);
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, Y, 0);
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, Z, 0);
	dynamicsWorld->setGravity(btVector3(X, Y, Z));
}

#define TRACE_BEGIN(x) \
	int __trace__##x__ = 0

#define TRACE(x) \
	[[api log] add: info withFormat: @"Tracing \""#x"\": %d;", __trace__##x__++]

MP_HANDLER_OF_MESSAGE(explosion)
{
	//===== loading params =============
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, X, 0);
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, Y, 0);
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, Z, 0);
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, radius, 0);
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, impulseCoefficient, 0);
	MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(MP_MESSAGE_DATA, maximalImpulse, -1);

	//===== initialization =============

	btCollisionShape *groundShape = new btSphereShape(radius);

	btGhostObject *explosionSphere = new btGhostObject();
	explosionSphere->setCollisionShape(groundShape);

	btVector3 explosionEye(X, Y, Z);

	btTransform trans;
	trans.setOrigin(explosionEye);

	explosionSphere->setWorldTransform(trans);

	explosionSphere->setCollisionFlags(explosionSphere->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);

	[worldLockMutex lock];
	dynamicsWorld->addCollisionObject(explosionSphere);
	[worldLockMutex unlock];

	//===== performing explosion =======

	int i, objcount;
	objcount = explosionSphere->getNumOverlappingObjects();
	for (i=0; i<objcount; ++i)
	{
		btRigidBody *explodingObject = btRigidBody::upcast(explosionSphere->getOverlappingObject(i));
		if (explodingObject)
		{
			btVector3 explodingImpulse(explosionEye);
			explodingImpulse -= explodingObject->getWorldTransform().getOrigin();

			double len = explodingImpulse.length();
			len *= len;
			explodingImpulse *= -1; //reverse
			explodingImpulse.normalize();
			if (len <= MPB_EPSILON)
			{
				continue;
			}
			len = impulseCoefficient/len;
			if ((maximalImpulse > 0) && (abs(len) > maximalImpulse))
			{
				len = len > 0 ? maximalImpulse : -maximalImpulse;
			}
			explodingImpulse *= len;
			explodingObject->applyCentralImpulse(explodingImpulse);
		}
	}


	//===== deinitialization ===========

	[worldLockMutex lock];
	dynamicsWorld->removeCollisionObject(explosionSphere);
	[worldLockMutex unlock];
	delete explosionSphere;
	delete groundShape;
	
}

@end


