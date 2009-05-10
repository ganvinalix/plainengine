#import <MPForkedThreadStrategy.h>
#import <MPAssertionHandler.h>
#import <common.h>

@implementation MPForkedThreadStrategy
// init
- init
{
	[super init];
	// initializing mutexes
	stateMutex = [[NSRecursiveLock alloc] init];
	accessMutex = [[NSRecursiveLock alloc] init];
	// initializing states
	working = NO;
	done = YES;
	paused = NO;

	return self;
}
- (void) dealloc
{
	[stateMutex release];
	[accessMutex release];
	//
	[super dealloc];
}
// creates specific notification queue
- (MPNotificationQueue *) newNotificationQueue
{
	return [[MPNotificationQueue alloc] init];
}
// mutex
- (void) lockMutex
{
	[accessMutex lock];
}
- (void) unlockMutex
{
	[accessMutex unlock];
}
// start performing thread subroutine
- (void) startPerformingSelector: (SEL)aSelector toTarget: (id)target
{
	selector = aSelector;
	thread = target;
	[NSThread detachNewThreadSelector: @selector(proxyRoutine) toTarget: self withObject: nil];
	[gLog add: notice withFormat: @"MPForkedThreadStrategy: %@ forked.", thread];
}
// states
- (BOOL) isWorking
{
	BOOL isWorking = NO;
	[stateMutex lock];
	isWorking = working;
	[stateMutex unlock];

	return isWorking;
}
- (void) setWorking: (BOOL)aState
{
	[stateMutex lock];
	working = aState;
	[stateMutex unlock];
}
- (BOOL) isDone
{
	BOOL isDone = NO;
	[stateMutex lock];
	isDone = done;
	[stateMutex unlock];

	return isDone;
}
- (void) setDone: (BOOL)aState
{
	[stateMutex lock];
	done = aState;
	[stateMutex unlock];
}
- (BOOL) isPaused
{
	BOOL isPaused = NO;
	[stateMutex lock];
	isPaused = paused;
	[stateMutex unlock];

	return isPaused;
}
- (void) setPaused: (BOOL)aState
{
	[stateMutex lock];
	paused = aState;
	[stateMutex unlock];
}
- (BOOL) isPrepared
{
	BOOL isPrepared = NO;
	[stateMutex lock];
	isPrepared = prepared;
	[stateMutex unlock];

	return isPrepared;
}
- (void) setPrepared: (BOOL)aState
{
	[stateMutex lock];
	prepared = aState;
	[stateMutex unlock];
}
- (BOOL) isUpdating
{
	BOOL isUpdating = NO;
	[stateMutex lock];
	isUpdating = updating;
	[stateMutex unlock];

	return isUpdating;
}
- (void) setUpdating: (BOOL)aState
{
	[stateMutex lock];
	updating = aState;
	[stateMutex unlock];
}

- (void) wait
{
	[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.001]];
}
- (void)proxyRoutine
{
	MPAutoreleasePool *pool = [[MPAutoreleasePool alloc] init];
	
	// set exception handler with blackjack and hookers
	MPBindAssertionHandlerToThread([NSThread currentThread]);

	//NSUInteger counter=0;
	[self setWorking: YES];
	while(![self isDone])
	{
		[thread performSelector: selector];
		/*++counter;
		if (counter>=cleanInterval)
		{
			counter = 0;
			[pool clean];
		}
		*/
		if ([pool size] > MPTHREAD_CLEAN_POOL_THRESHOLD)
		{
			[pool clean];
		}
	}
	[self setWorking: NO];

	[pool release];
}

- (void) update
{

}
@end

