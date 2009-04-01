#import <MPThreadStrategy.h>
#import <MPSubroutineThreadStrategy.h>
#import <MPForkedThreadStrategy.h>
#import <config.h>

@implementation MPThreadStrategy
+ forkedStrategy
{
	return [[[MPForkedThreadStrategy alloc] init] autorelease];
}
+ subroutineStrategy
{
	return [[[MPSubroutineThreadStrategy alloc] init] autorelease];
}
//
- init
{
	[super init];
	return nil;
}
// creates specific notification queue
- (MPNotificationQueue *) newNotificationQueue
{
	return [MPNotificationQueue notificationQueue];
}
// mutex
- (void) lockMutex
{
}
- (void) unlockMutex
{
}
// start performing thread subroutine
- (void) startPerformingSelector: (SEL)aSelector toTarget: (id)target
{
}
// states
- (BOOL) isWorking
{
	return NO;
}
- (void) setWorking: (BOOL)aState
{
}
- (BOOL) isDone
{
	return NO;
}
- (void) setDone: (BOOL)aState
{
}
- (BOOL) isPaused
{
	return NO;
}
- (void) setPaused: (BOOL)aState
{
}
- (BOOL) isPrepared
{
	return NO;
}
- (void) setPrepared: (BOOL)aState
{
}
- (BOOL) isUpdating
{
	return NO;
}
- (void) setUpdating: (BOOL)aState
{
}

- (void) wait
{
}
- (void) update
{
}
@end


