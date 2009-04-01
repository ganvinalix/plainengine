#import <MPSubroutineThreadStrategy.h>
#import <MPUtility.h>
#import <common.h>

@implementation MPSubroutineThreadStrategy
// init
- init
{
	[super init];
	// initializing states
	working = NO;
	done = YES;
	paused = NO;
	// init timer 
	_timer = nil;
	// innerPool
	counter = 0;
	return self;
}
- (void) dealloc
{
	[innerPool release];
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
	// do nothing
}
- (void) unlockMutex
{
	// do nothing
}
// start performing thread subroutine
- (void) startPerformingSelector: (SEL)aSelector toTarget: (id)target
{
	innerPool = [MPAutoreleasePool new];
	//[[NSRunLoop currentRunLoop] performSelector: aSelector target: target argument: nil order: 0 modes: [NSArray arrayWithObjects: NSDefaultRunLoopMode, nil]]; 
	[self setWorking: YES];

	_timer = [NSTimer scheduledTimerWithTimeInterval: 0.0 target: target selector: aSelector userInfo: nil repeats: YES];
	[gLog add: notice withFormat: @"MPSubroutineThreadStrategy: %@ started as subroutine.", target];
}
// states
- (BOOL) isWorking
{
	return working;
}
- (void) setWorking: (BOOL)aState
{
	working = aState;
}
- (BOOL) isDone
{
	return done;
}
- (void) setDone: (BOOL)aState
{
	done = aState;

	if(done)
	{
		if(_timer)
			[_timer invalidate];
		_timer = nil;
	}

	[self setWorking: NO];
}
- (BOOL) isPaused
{
	return paused;
}
- (void) setPaused: (BOOL)aState
{
	paused = aState;
}
- (BOOL) isPrepared
{
	return prepared;
}
- (void) setPrepared: (BOOL)aState
{
	prepared = aState;
}
- (BOOL) isUpdating
{
	return updating;
}
- (void) setUpdating: (BOOL)aState
{
	updating = aState;
}
- (void) wait
{
	[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.1]];
}
- (void) update
{
	if ([innerPool size] > MPTHREAD_CLEAN_POOL_THRESHOLD)
	{
		[innerPool clean];
	}
	/*
	++counter;
	if (counter>=cleanInterval)
	{
		counter = 0;
		[innerPool clean];
		printf("cleaned;\n");
	}
	*/
}
@end

