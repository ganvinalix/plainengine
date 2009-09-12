#import <Foundation/Foundation.h>
#import <MPSpinLock.h>
#import <MPQueue.p>

@interface MPSynchronizedQueue: NSObject <MPQueue>
{
	NSMutableArray *queue;
	MPSpinLock *mutex;
}

-init;
-(void) dealloc;

@end

