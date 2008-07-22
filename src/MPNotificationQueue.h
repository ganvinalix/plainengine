#import <Foundation/Foundation.h>

@interface MPNotificationQueue : NSObject
{
	// the FIFO
	NSMutableArray *notifications;
	// synchronization object
	NSLock *theLock;
}
// receives notifications and adds them to the FIFO
- (void) receiveNotification: (NSNotification *)anNotification;

// gets the element from FIFO's top
// (method just returns pointer and doesn't retain object)
- (NSNotification *) getTop;
// removes the top element of FIFO
- (void) popTop;

// factory method
+ notificationQueue;
@end

