#import <MPThread.h>

@implementation MPThread
//
- init
{
	[super init];

	accessMutex = [[NSLock alloc] init];
	notifications = [[MPNotificationQueue alloc] init];
	[[NSNotificationCenter defaultCenter] addObserver: notifications selector:@selector(receiveNotification:) name: @"plainNotification" object: nil];
	inWork = NO;
	mustWork = NO;
	subjects = [[NSMutableDictionary alloc] init];
	return self;
}
- (void) dealloc
{
	[self stop];
	[accessMutex release];
	[subjects release];
	[[NSNotificationCenter defaultCenter] removeObserver: notifications];
	[notifications release];

	[super dealloc];
}
+ thread
{
	return [[[MPThread alloc] init] autorelease];
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
	[NSThread detachNewThreadSelector: @selector(threadRoutine) toTarget: self withObject: nil];
}
- (void) stop
{
	[accessMutex lock];
	mustWork = NO;
	[accessMutex unlock];
	// waiting until forked thread join us 
	while( [self isWorking] )
	{
		[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.5]];
	}
}
//-----
- (void) threadRoutine
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
		while( (notification = [notifications getTop]) != nil )
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

//
- (BOOL) addSubject: (id<MPSubject>)aSubject withName: (NSString *)aName
{
	if ([subjects objectForKey: aName])
	{
		return NO;
	}
	[subjects setObject: aSubject forKey: aName];
	return YES;
}

- (BOOL) removeSubjectWithName: (NSString *)aName
{
	id subj;
	subj = [subjects objectForKey: aName];
	if (!subj)
	{
		return NO;
	}
	[subjects removeObjectForKey: aName];
	[subj release];
	return YES;
}

- (void) pause
{}
- (void) resume
{}

@end

