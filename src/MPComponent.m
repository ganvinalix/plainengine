#import <MPComponent.h>

@implementation MPComponent
//
- init
{
	[super init];

	accessMutex = [[NSLock alloc] init];
	notifications = [[MPNotificationQueue alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver: notifications selector:@selector(receiveNotification:) name: @"plainNotification" object: nil];
	inWork = NO;
	mustWork = NO;

	return self;
}
- (void) dealloc
{
	[self stop];
	[accessMutex release];
	[[NSNotificationCenter defaultCenter] removeObserver: notifications];
	[notifications release];

	[super dealloc];
}
+ component
{
	return [[[MPComponent alloc] init] autorelease];
}
//-----
- (BOOL) isWorking
{
	BOOL isWorking = NO;
	[accessMutex lock];
	isWorking = inWork;
	[accessMutex unlock];
	return isWorking;
}
- (void) start
{
	if( [self isWorking] ) return;

	mustWork = YES;
	[NSThread detachNewThreadSelector: @selector(componentThreadRoutine) toTarget: self withObject: nil];
}
- (void) stop
{
	[accessMutex lock];
	mustWork = NO;
	[accessMutex unlock];
	while( [self isWorking] )
	{
		[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.5]];
	}
}
//-----
- (void) componentThreadRoutine
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	[accessMutex lock];
	inWork = YES;
	[accessMutex unlock];

	BOOL done = NO;
	while( !done )
	{
		[accessMutex lock];
		done = !mustWork;
		[accessMutex unlock];

		printf("\"hi there!\" says %s thread\n", [[[NSThread currentThread] description] UTF8String] );
		NSNotification *notification = nil;
		while( notification = [notifications getTop] )
		{
			printf("Notification: [%s] has been received by %s\n", [[notification name] UTF8String], [[[NSThread currentThread] description] UTF8String] );
			[notifications popTop];
		}
		[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.5]];
	}

	[accessMutex lock];
	inWork = NO;
	[accessMutex unlock];

	[pool release];
}
@end

