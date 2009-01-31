#import <MPCore.h>
#import <btBulletDynamicsCommon.h>

@protocol MPPhysicalObject <NSObject>

-(double) getX;
-(double) getY;
-(double) getZ;

-(double) getRoll;
-(double) getRotationQuaternionX;
-(double) getRotationQuaternionY;
-(double) getRotationQuaternionZ;
-(double) getRotationQuaternionW;

-(double) getRadius; //bounding sphere

-(void) setXYZ: (double)aX : (double)aY : (double)aZ;
-(void) setYZ: (double)aY : (double)aZ;
-(void) setXZ: (double)aX : (double)aZ;
-(void) setXY: (double)aX : (double)aY;

-(void) setRoll: (double)val;
-(void) setRotationQuaternionXYZW: (double)aX : (double)aY : (double)aZ : (double)aW;

-(void) applyForceWithXYZ: (double)aX : (double)aY : (double)aZ relativePosWithXYZ: (double)rX : (double)rY : (double)rZ;
-(void) applyImpulseWithXYZ: (double)aX : (double)aY : (double)aZ relativePosWithXYZ: (double)rX : (double)rY : (double)rZ;
-(void) applyTorqueWithXYZ: (double)aX : (double)aY : (double)aZ;

-(void) setGravityWithXYZ: (double)aX : (double)aY : (double)aZ;
-(void) setLinearVelocityWithXYZ: (double)aX : (double)aY : (double)aZ;

@end

@interface MPPhysicalObjectDelegate : NSObject <MPPhysicalObject>
{
	double X, Y, Z;
	double qX, qY, qZ, qW;
	double Roll;
	bool manuallyMoving;
	id connectedObject;
	btRigidBody *bulletObject;
	btGeneric6DofConstraint *constrict;
	btCollisionShape *groundShape;
	btMotionState *motionState;
}


-initWithObject: (id<MPObject>)object;
+newDelegateWithObject: (id<MPObject>)object;

+(void) setAPI: (id<MPAPI>)api;
+(void) setWorld: (btDynamicsWorld *)world;
+(void) setCleaningVelocityOnManualMove: (BOOL)flag;

-(void) setFeature: (NSString *)featureName toValue: (id<MPVariant>)data userInfo: (id)userInfo;
-(void) removeFeature: (NSString *)featureName;

-(void) startInternalChanging;
-(void) stopInternalChanging;

-(btCollisionObject *) getBulletObject;

-(void) dealloc;

@end

extern NSLock *worldLock;

