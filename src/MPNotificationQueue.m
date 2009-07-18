#import <MPNotificationQueue.h>

@implementation MPNotificationQueue

// init method
- init
{
	[super init];
	notifications = [[NSMutableArray alloc] initWithCapacity: 100];
	theLock = [[MPSpinLock alloc] init];
	return self;
}
// dealloc method
- (void) dealloc
{
	[theLock release];
	[notifications release];
	[super dealloc];
}

// factory method
+ notificationQueue
{
	return [[[MPNotificationQueue alloc] init] autorelease];
}

// accessors 
- (void) popTop
{
	[theLock lock];
	if([notifications count])
		[notifications removeObjectAtIndex: 0];
	[theLock unlock];
}
- (NSNotification *) getTop
{
	id obj = nil;

	[theLock lock];
	if([notifications count]) 
		obj = [notifications objectAtIndex: 0];
	[theLock unlock];

	return obj;
}

// notifications receiver
- (void) receiveNotification: (NSNotification *)anNotification
{
	if(anNotification)
	{
		[theLock lock];
		[notifications addObject: anNotification];
		[theLock unlock];
	}
}

- (NSString*) description
{
	return [notifications description];
}
@end


