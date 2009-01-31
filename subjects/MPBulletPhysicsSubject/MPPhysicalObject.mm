#import <MPPhysicalObject.h>
#import <MPBMotionState.h>
#import <MPBulletPhysicsHelpers.h>
#import <MPBulletPhysicsGlobalParams.h>

id<MPAPI> globalAPI = nil;
btDynamicsWorld *globalWorld = NULL;

BOOL cleanVelocityOnManualMove = NO;

@implementation MPPhysicalObjectDelegate

-initWithObject: (id<MPObject>)object
{
	[super init];

	X=Y=Z=0;
	qX=qZ=qW=0;
	qY=1;
	Roll=0;
	connectedObject = object;	
	bulletObject = NULL;
	constrict = NULL;
	groundShape = NULL;
	motionState = NULL;
	manuallyMoving = YES;

	return self;
}

+newDelegateWithObject: (id<MPObject>)object
{
	return [[self alloc] initWithObject: object];
}

+(void) setAPI: (id<MPAPI>)api
{
	globalAPI = api;
}

+(void) setWorld: (btDynamicsWorld *)world
{
	globalWorld = world;
}

+(void) setCleaningVelocityOnManualMove: (BOOL)flag
{
	cleanVelocityOnManualMove = flag;
}

-(void) startInternalChanging
{
	manuallyMoving = NO;
}

-(void) stopInternalChanging
{
	manuallyMoving = YES;
}

-(void) setFeature: (NSString *)featureName toValue: (id<MPVariant>)data userInfo: (id)userInfo
{
	if ([featureName isEqualToString: @"mass"])
	{
		btVector3 localInertia(0,0,0);
		double mass = [data doubleValue];
		if (mass)
		{
			groundShape->calculateLocalInertia(mass, localInertia);
		}
		bulletObject->setMassProps(mass, localInertia);
	}
	else if ([featureName isEqualToString: @"friction"])
	{
		bulletObject->setFriction([data doubleValue]);
	}
	else if ([featureName isEqualToString: @"restitution"])
	{
		bulletObject->setRestitution([data doubleValue]);
	}
	else if ([featureName isEqualToString: @"kinematic"])
	{
		bulletObject->setCollisionFlags(bulletObject->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
	}
	else if (!bulletObject && [featureName isEqualToString: @"physical"])
	{
		groundShape = getShape(userInfo);
		
		btVector3 localInertia(0,0,0);
		double mass = [[connectedObject getFeatureData: @"mass"] doubleValue];
		double friction = [[connectedObject getFeatureData: @"friction"] doubleValue];
		double restitution = [[connectedObject getFeatureData: @"restitution"] doubleValue];
		if (mass)
		{
			groundShape->calculateLocalInertia(mass, localInertia);
		}
		motionState = new MPBMotionState(connectedObject);
		btRigidBody::btRigidBodyConstructionInfo rbInfo(mass, motionState, groundShape, localInertia);
		bulletObject = new btRigidBody(rbInfo);
		bulletObject->setFriction(friction);
		bulletObject->setRestitution(restitution);
		bulletObject->setUserPointer(connectedObject);
		bulletObject->setCollisionFlags(bulletObject->getCollisionFlags() | btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK);
		bulletObject->setSleepingThresholds(linearVelocitySleepingThreshold, angularVelocitySleepingThreshold);
		//bulletObject->setDamping(0.9f, 0.9f);
		if ([connectedObject hasFeature: @"kinematic"])
		{
			bulletObject->setCollisionFlags(bulletObject->getCollisionFlags() | btCollisionObject::CF_KINEMATIC_OBJECT);
		}
		if (disableObjectDeactivation)
		{
			bulletObject->setActivationState(DISABLE_DEACTIVATION);
		}
		[worldLockMutex lock];
		globalWorld->addRigidBody(bulletObject);
		[worldLockMutex unlock];

		if (mode2D)
		{
			constrict = new btGeneric6DofConstraint(*bulletObject, *zeroBody,
								btTransform::getIdentity(), btTransform::getIdentity(), false);
			constrict->setLimit(disabledAxis, 0, 0);
			constrict->setLimit(enabledAxis1, 1, 0);
			constrict->setLimit(enabledAxis2, 1, 0);
			constrict->setLimit(disabledAxis+3, 1, 0);
			constrict->setLimit(enabledAxis1+3, 0, 0);
			constrict->setLimit(enabledAxis2+3, 0, 0);

			globalWorld->addConstraint(constrict);
		}
	}
}

-(void) removeFeature: (NSString *)featureName
{
	if ([featureName isEqualToString: @"kinematic"])
	{
		bulletObject->setCollisionFlags(bulletObject->getCollisionFlags() & !(btCollisionObject::CF_KINEMATIC_OBJECT));
	}
	else if ([featureName isEqualToString: @"physical"])
	{
		if (bulletObject)
		{
			if (constrict)
			{
				globalWorld->removeConstraint(constrict);
				delete constrict;
			}
			[worldLockMutex lock];
			globalWorld->removeCollisionObject(bulletObject);
			[worldLockMutex unlock];
			delete bulletObject;
			delete motionState;
			bulletObject = NULL;
			motionState = NULL;
		}
	}
}

-(btCollisionObject *) getBulletObject
{
	return bulletObject;
}

-(void) dealloc
{
	if (bulletObject)
	{
		if (constrict)
		{
			globalWorld->removeConstraint(constrict);
			delete constrict;
		}
		[worldLockMutex lock];
		globalWorld->removeCollisionObject(bulletObject);
		[worldLockMutex unlock];
		delete bulletObject;
		delete motionState;
	}
	[super dealloc];
}

-(void) applyForceWithXYZ: (double)aX : (double)aY : (double)aZ relativePosWithXYZ: (double)rX : (double)rY : (double)rZ
{
	if (bulletObject)
	{
		bulletObject->applyForce(btVector3(aX, aY, aZ), btVector3(rX, rY, rZ));
	}
}

-(void) applyImpulseWithXYZ: (double)aX : (double)aY : (double)aZ relativePosWithXYZ: (double)rX : (double)rY : (double)rZ
{
	if (bulletObject)
	{
		bulletObject->applyImpulse(btVector3(aX, aY, aZ), btVector3(rX, rY, rZ));
	}
}

-(void) applyTorqueWithXYZ: (double)aX : (double)aY : (double)aZ
{
	if (bulletObject)
	{
		bulletObject->applyTorque(btVector3(aX, aY, aZ));
	}
}

-(void) setGravityWithXYZ: (double)aX : (double)aY : (double)aZ
{
	if (bulletObject)
	{
		bulletObject->setGravity(btVector3(aX, aY, aZ));
	}
}

-(void) setLinearVelocityWithXYZ: (double)aX : (double)aY : (double)aZ
{
	if (bulletObject)
	{
		bulletObject->setLinearVelocity(btVector3(aX, aY, aZ));
		bulletObject->activate(true);
	}
}

-(void) setXYZ: (double)aX : (double)aY : (double)aZ
{
	X=aX;
	Y=aY;
	Z=aZ;
	if (bulletObject && manuallyMoving)
	{
		btVector3 origin(aX, aY, aZ);
		btTransform trans(bulletObject->getWorldTransform());
		trans.setOrigin(origin);
		bulletObject->setWorldTransform(trans);
		if (cleanVelocityOnManualMove)
		{
			bulletObject->setLinearVelocity(btVector3(0,0,0));	
		}
		bulletObject->activate(true);
	}
}

-(void) setYZ: (double)aY : (double)aZ
{
	[connectedObject setXYZ:[self getX]:aY:aZ];
}

-(void) setXZ: (double)aX : (double)aZ
{
	[connectedObject setXYZ:aX:[self getY]:aZ];
}

-(void) setXY: (double)aX : (double)aY
{
	[connectedObject setXYZ:aX:aY:[self getZ]];
}

-(void) setRoll: (double)val
{
	Roll = val;
	double axis[3];
	axis[disabledAxis] = 1;
	axis[enabledAxis1] = 0;
	axis[enabledAxis2] = 0;
	if (bulletObject)
	{
		btQuaternion rot;
		btTransform trans(bulletObject->getWorldTransform());
		rot.setRotation(btVector3(axis[0], axis[1], axis[2]), val);
		trans.setRotation(rot);
		bulletObject->setWorldTransform(trans);
		bulletObject->activate(true);
	}
}

-(void) setRotationQuaternionXYZW: (double)aX : (double)aY : (double)aZ : (double)aW
{
	qX=aX;
	qY=aY;
	qZ=aZ;
	qW=aW;
	if (bulletObject && manuallyMoving)
	{
		btQuaternion rot(aX, aY, aZ, aW);
		btTransform trans(bulletObject->getWorldTransform());
		trans.setRotation(rot);
		bulletObject->setWorldTransform(trans);
		bulletObject->activate(true);
	}
}

-(double) getX
{
	return X;
}

-(double) getY
{
	return Y;
}

-(double) getZ
{
	return Z;
}

-(double) getRoll
{
	return Roll;
}

-(double) getRotationQuaternionX
{
	return qX;
}

-(double) getRotationQuaternionY
{
	return qY;
}

-(double) getRotationQuaternionZ
{
	return qZ;
}

-(double) getRotationQuaternionW
{
	return qW;
}

-(double) getRadius
{
	btVector3 temp;
	btScalar radius(0);
	if (bulletObject)
	{
		bulletObject->getCollisionShape()->getBoundingSphere(temp, radius);		
	}
	return radius;
}

@end

