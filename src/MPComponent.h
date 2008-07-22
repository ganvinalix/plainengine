#import <Foundation/Foundation.h>
#import <MPNotificationQueue.h>

@interface MPComponent : NSObject
{
	NSLock *accessMutex;
	MPNotificationQueue *notifications;
	BOOL inWork;
	BOOL mustWork;
}
- init;
- (void) dealloc;
+ component;
//
- (BOOL) isWorking;
- (void) start;
- (void) stop;
// 
- (void) componentThreadRoutine;
@end
