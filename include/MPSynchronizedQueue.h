#import <Foundation/Foundation.h>
#import <MPSpinLock.h>

@interface MPSynchronizedQueue: NSObject
{
	NSMutableArray *queue;
	MPSpinLock *mutex;
}

-init;
-(void) dealloc;

-(void) push: (id)elem;
-(id) pop;

@end

