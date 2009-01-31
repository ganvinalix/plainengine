#import <MPGhostObject.h>
#import <MPBulletPhysicsHelpers.h>
#import <MPBulletPhysicsGlobalParams.h>

btDynamicsWorld *gWorld;

@implementation MPGhostObjectDelegate

-initWithObject: (id<MPObject>)object
{
	[super init];

	X=Y=Z=Roll=0;
	qX=qZ=qW=0;
	qY=1;
	connectedObject = object;	
	bulletObject = NULL;
	groundShape = NULL;

	return self;
}

+newDelegateWithObject: (id<MPObject>)object
{
	return [[self alloc] initWithObject: object];
}

+(void) setWorld: (btDynamicsWorld *)world
{
	gWorld = world;
}

-(void) setFeature: (NSString *)featureName toValue: (id<MPVariant>)data userInfo: (id)userInfo
{
	if (!bulletObject && [featureName isEqualToString: @"ghostobject"])
	{
		groundShape = getShape(userInfo);
		
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

		bulletObject->setUserPointer(connectedObject);
		bulletObject->setCollisionFlags(bulletObject->getCollisionFlags() | btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK);
		//[worldLockMutex lock];
		gWorld->addCollisionObject(bulletObject);
		//[worldLockMutex unlock];
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

-(double) getRoll
{
	return Roll;
}

-(void) setXYZ: (double)aX : (double)aY : (double)aZ
{
	X=aX;
	Y=aY;
	Z=aZ;
	if (mode2D)
	{
		switch (disabledAxis)
		{
			case 0: aX=0; break;
			case 1: aY=0; break;
			case 2: aZ=0; break;
		}
	}
	if (bulletObject)
	{
		btVector3 origin(aX, aY, aZ);
		btTransform trans = bulletObject->getWorldTransform();
		trans.setOrigin(origin);
		bulletObject->setWorldTransform(trans);
	}
}

-(void) setYZ: (double)aY : (double)aZ
{
	[self setXYZ:[self getX]:aY:aZ];
}

-(void) setXZ: (double)aX : (double)aZ
{
	[self setXYZ:aX:[self getY]:aZ];
}

-(void) setXY: (double)aX : (double)aY
{
	[self setXYZ:aX:aY:[self getZ]];
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
	}
}

-(void) setRotationQuaternionXYZW: (double)aX : (double)aY : (double)aZ : (double)aW
{
	qX=aX;
	qY=aY;
	qZ=aZ;
	qW=aW;
	if (bulletObject)
	{
		btQuaternion rot(aX, aY, aZ, aW);
		btTransform trans(bulletObject->getWorldTransform());
		trans.setRotation(rot);
		bulletObject->setWorldTransform(trans);
	}
}



-(void) dealloc
{
	if (bulletObject)
	{
		//[worldLockMutex lock];
		gWorld->removeCollisionObject(bulletObject);
		//[worldLockMutex unlock];
		delete groundShape;
		delete bulletObject;
	}
	[super dealloc];
}

@end

