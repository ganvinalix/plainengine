#import <Foundation/Foundation.h>
#import <btBulletDynamicsCommon.h>

#define MPB_EPSILON 0.00001f

extern BOOL mode2D;
extern BOOL disableObjectDeactivation;
extern int disabledAxis;
extern int enabledAxis1, enabledAxis2;
extern btRigidBody *zeroBody;

extern double linearVelocitySleepingThreshold;
extern double angularVelocitySleepingThreshold;

extern BOOL disableCalculateAttractedObjects;

extern NSLock *worldLockMutex;

