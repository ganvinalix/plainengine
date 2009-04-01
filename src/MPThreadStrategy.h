#import <Foundation/Foundation.h>
#import <MPNotificationQueue.h>

@interface MPThreadStrategy : NSObject
// creates specific notification queue
- (MPNotificationQueue *) newNotificationQueue;
// factory methods
+ forkedStrategy;
+ subroutineStrategy;
// mutex
- (void) lockMutex;
- (void) unlockMutex;
// start performing thread subroutine
- (void) startPerformingSelector: (SEL)aSelector toTarget: (id)target;
- (void) wait;
// states
- (BOOL) isWorking; 
- (void) setWorking: (BOOL)aState;
- (BOOL) isDone;
- (void) setDone: (BOOL)aState;
- (BOOL) isPaused;
- (void) setPaused: (BOOL)aState;
- (BOOL) isPrepared;
- (void) setPrepared: (BOOL)aState;
- (BOOL) isUpdating;
- (void) setUpdating: (BOOL)aState;
// update
- (void) update;
@end


