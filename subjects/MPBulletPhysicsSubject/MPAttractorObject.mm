#import <MPAttractorObject.h>
#import <MPBulletPhysicsHelpers.h>
#import <MPBulletPhysicsGlobalParams.h>

btDynamicsWorld *attractorObjectWorld = NULL;

@protocol MPBPSAttracted
-(BOOL) canBeAttractedTo: (id<MPObject>)attractor;
@end

#define MPAO_ATTRACTOR_TYPE_MAGNETIC 0
#define MPAO_ATTRACTOR_TYPE_SPRING 1

@implementation MPAttractorObject

BOOL isAttractorOf(NSString *attr, id<MPObject> obj)
{
	//return[[[obj getFeatureData: @"attracted"] stringValue] isEqualToString: attr];
	NSString *attrs = [[obj getFeatureData: @"attracted"] stringValue];
	return [[attrs componentsSeparatedByString: @" "] containsObject: attr];
}

void setAttractorTo(NSString *attr, id<MPObject> obj)
{
	//[obj setFeature: @"attracted" toValue: [MPVariant variantWithString: attr]];
	if (![obj hasFeature: @"attracted"])
	{
		[obj setFeature: @"attracted" toValue: [MPVariant variantWithString: attr]];
	}
	else
	{
		NSString *prev = [[obj getFeatureData: @"attracted"] stringValue];
		[obj setFeature: @"attracted" toValue:
						[MPVariant variantWithString: [NSString stringWithFormat: @"%@ %@", prev, attr]]];
	}
}

void removeAttractorFrom(NSString *attr, id<MPObject> obj)
{
	//[obj removeFeature: @"attracted"];
	if (![obj hasFeature: @"attracted"])
	{
		return;
	}
	NSMutableArray *attrs =
		[[[[obj getFeatureData: @"attracted"] stringValue] componentsSeparatedByString: @" "] mutableCopy];
	[attrs removeObject: attr];
	if ([attrs count])
	{
		[obj setFeature: @"attracted" toValue: [MPVariant variantWithString: [attrs componentsJoinedByString: @" "]]];
	}
	else
	{
		[obj removeFeature: @"attracted"];
	}
}

-(NSMutableArray *) getAttractedObjects //for internal use only!!
{
	return attractedObjects;
}

+(void) updateWorldWithAPI: (id<MPAPI>)api byTime: (double)time
{
	if (!api)
	{
		return;
	}
	
	NSArray *attractors = [[api getObjectSystem] getObjectsByFeature: @"attractor"];
	NSUInteger i, attrcount = [attractors count];
	for (i=0; i<attrcount; ++i)
	{
		id attractorObject = [attractors objectAtIndex: i];
		[attractorObject lock];
		if (![attractorObject hasFeature: @"attractor"])
		{
			//attractor had been already deleted
			[attractorObject unlock];
			continue;
		}
		btGhostObject *curAttractor = dynamic_cast<btGhostObject *>
														([attractorObject getAttractorObject]);
		if (!curAttractor)
		{
			[attractorObject unlock];
			continue;
		}

		//double radius = [[attractorObject getFeatureData: @"mass"] doubleValue];
		if ([attractorObject getAttractedObjects])
		{
			[[attractorObject getAttractedObjects] removeAllObjects];
		}

		NSString *attractorObjectName = NULL;
		NSMutableArray *oldAttractedObjects = NULL;

		if (!disableCalculateAttractedObjects)
		{
			attractorObjectName = [attractorObject getName];
			//attractorObjectNameAsVariant = [MPVariant variantWithString: attractorObjectName];
			oldAttractedObjects = [[[api getObjectSystem] getObjectsByFeature: @"attracted"] mutableCopy];
			NSUInteger z, attrobjcnt = [oldAttractedObjects count];
			for (z=0; z<attrobjcnt; ++z)
			{
				id obj = [oldAttractedObjects objectAtIndex: z];
				//if (![[[obj getFeatureData: @"attracted"] stringValue] isEqualToString: attractorObjectName])
				if (!isAttractorOf(attractorObjectName, obj))
				{
					[oldAttractedObjects removeObjectAtIndex: z];
					--z;
					--attrobjcnt;
				}
			}
		}
		//double radius = [[[attractors objectAtIndex: i] getFeatureData: @"attractingRadius"] doubleValue];
		double k = [[[attractors objectAtIndex: i] getFeatureData: @"attractingImpulseCoefficient"] doubleValue];
		int type = MPAO_ATTRACTOR_TYPE_MAGNETIC;
		if ([[[[attractors objectAtIndex: i] getFeatureData: @"attractorType"] stringValue] isEqualToString: @"spring"])
		{
			type = MPAO_ATTRACTOR_TYPE_SPRING;
		}
		btVector3 attractorPos = curAttractor->getWorldTransform().getOrigin();

		int j, objcount;
		objcount = curAttractor->getNumOverlappingObjects();
		for (j=0; j<objcount; ++j)
		{
			btRigidBody *attracted = btRigidBody::upcast(curAttractor->getOverlappingObject(j));
			if (attracted)
			{
				id attractedObject = id(attracted->getUserPointer());
				if ([attractedObject respondsToSelector: @selector(canBeAttractedTo:)])
				{
					if (![attractedObject canBeAttractedTo: attractorObject])
					{
						continue;
					}
				}
				double mass = [[attractedObject getFeatureData: @"mass"] doubleValue];
				if (mass == 0.f)
				{
					continue;
				}

				if ([attractedObject isEqual: attractorObject])
				{
					continue;
				}

				btVector3 attractingImpulse(attractorPos);
				attractingImpulse -= attracted->getWorldTransform().getOrigin();

				if (type == MPAO_ATTRACTOR_TYPE_MAGNETIC)
				{
					double len = attractingImpulse.length();
					len *= len;
					if (len <= MPB_EPSILON)
					{
						continue;
					}
					attractingImpulse.normalize();
					attractingImpulse /= len;
				}
				attractingImpulse *= k;
				attractingImpulse *= mass;
				attractingImpulse *= time;
				attracted->applyCentralImpulse(attractingImpulse);

				if (!disableCalculateAttractedObjects)
				{
					//if ([attractedObject hasFeature: @"attracted"])
					if (isAttractorOf(attractorObjectName, attractedObject))
					{
						[oldAttractedObjects removeObject: attractedObject];
					}
					else
					{
						setAttractorTo(attractorObjectName, attractedObject);
					}
				}
				[[attractorObject getAttractedObjects] addObject: attractedObject];
			}
		}
		if (!disableCalculateAttractedObjects)
		{
			//[oldAttractedObjects makeObjectsPerformSelector: @selector(removeFeature:)
			//									 withObject: @"attracted"];
			NSUInteger j, oaoc = [oldAttractedObjects count];
			for (j=0; j<oaoc; ++j)
			{
				removeAttractorFrom(attractorObjectName, [oldAttractedObjects objectAtIndex: j]);
			}
		}
		[oldAttractedObjects release];
		[attractorObject unlock];
	}
}

+(void) setWorld: (btDynamicsWorld *)world
{
	attractorObjectWorld = world;
}

-initWithObject: (id<MPObject>)object
{
	[super initWithObject: object];
	attractedObjects = [NSMutableArray new];
	return self;
}

-(btGhostObject *) getAttractorObject
{
	return bulletObject;
}

-(void) setFeature: (NSString *)featureName toValue: (id<MPVariant>)data userInfo: (id)userInfo
{
	if (!bulletObject && [featureName isEqualToString: @"attractor"])
	{
		double radius = [[connectedObject getFeatureData: @"attractingRadius"] doubleValue];
		groundShape = new btSphereShape(radius);

		bulletObject = new btGhostObject();
		bulletObject->setCollisionShape(groundShape);

		btQuaternion rot(
					[connectedObject getRotationQuaternionX],
					[connectedObject getRotationQuaternionY],
					[connectedObject getRotationQuaternionZ],
					[connectedObject getRotationQuaternionW]
					);
		btTransform trans;
		trans.setOrigin(btVector3([connectedObject getX], [connectedObject getY], [connectedObject getZ]));
		trans.setRotation(rot);

		bulletObject->setWorldTransform(trans);

		bulletObject->setCollisionFlags(bulletObject->getCollisionFlags() | btCollisionObject::CF_NO_CONTACT_RESPONSE);

		bulletObject->setUserPointer(connectedObject);
		//[worldLockMutex lock];
		attractorObjectWorld->addCollisionObject(bulletObject);
		//[worldLockMutex unlock];
	}
	else if ([featureName isEqualToString: @"attractingRadius"])
	{
		btCollisionShape *oldshape = groundShape;
		groundShape = new btSphereShape([data doubleValue]);
		bulletObject->setCollisionShape(groundShape);
		delete oldshape;
	}
}

-(void) removeFeature: (NSString *)featureName
{
	if ([featureName isEqualToString: @"attractor"])
	{
		NSString *name = [connectedObject getName];
		NSArray *attractedObjectsCopy = [attractedObjects copy];
		NSUInteger i, count = [attractedObjectsCopy count];
		for (i=0; i<count; ++i)
		{
			removeAttractorFrom(name, [attractedObjectsCopy objectAtIndex: i]);	
		}
		[attractedObjectsCopy release];
		[attractedObjects removeAllObjects];

		if (bulletObject)
		{
			//[worldLockMutex lock];
			attractorObjectWorld->removeCollisionObject(bulletObject);
			//[worldLockMutex unlock];
			delete groundShape;
			delete bulletObject;
			bulletObject = NULL;
		}
	}
}

-(void) dealloc
{	
	
	[attractedObjects release];
	[super dealloc];
}

@end

