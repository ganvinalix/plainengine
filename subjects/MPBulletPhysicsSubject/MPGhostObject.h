#import <MPCore.h>
#import <btBulletDynamicsCommon.h>
#import <BulletCollision/CollisionDispatch/btGhostObject.h>

@protocol MPGhostObject <NSObject>

-(double) getX;
-(double) getY;
-(double) getZ;

-(double) getRoll;
-(double) getRotationQuaternionX;
-(double) getRotationQuaternionY;
-(double) getRotationQuaternionZ;
-(double) getRotationQuaternionW;

-(void) setXYZ: (double)aX : (double)aY : (double)aZ;
-(void) setYZ: (double)aY : (double)aZ;
-(void) setXZ: (double)aX : (double)aZ;
-(void) setXY: (double)aX : (double)aY;

-(void) setRoll: (double)val;
-(void) setRotationQuaternionXYZW: (double)aX : (double)aY : (double)aZ : (double)aW;

@end

@interface MPGhostObjectDelegate : NSObject <MPGhostObject>
{
@protected
	double X, Y, Z;
	double Roll;
	double qX, qY, qZ, qW;
	id connectedObject;
	btGhostObject *bulletObject;
	btCollisionShape *groundShape;
}

-initWithObject: (id<MPObject>)object;
+newDelegateWithObject: (id<MPObject>)object;

+(void) setWorld: (btDynamicsWorld *)world;

-(void) setFeature: (NSString *)featureName toValue: (id<MPVariant>)data userInfo: (id)userInfo;

-(void) dealloc;

@end

