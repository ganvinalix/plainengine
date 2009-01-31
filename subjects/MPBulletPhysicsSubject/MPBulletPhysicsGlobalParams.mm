#import <MPBulletPhysicsGlobalParams.h>

BOOL mode2D=NO;
BOOL disableObjectDeactivation=NO;
int disabledAxis=-1;
int enabledAxis1=-1, enabledAxis2=-1;
btRigidBody *zeroBody=NULL;

double linearVelocitySleepingThreshold=0;
double angularVelocitySleepingThreshold=0;

BOOL disableCalculateAttractedObjects=NO;

NSLock *worldLockMutex = [NSRecursiveLock new];

