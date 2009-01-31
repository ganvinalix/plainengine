#import <MPNotificationQueue.h>

@implementation MPNotificationQueue

// init method
- init
{
	[super init];
	notifications = [[NSMutableArray alloc] initWithCapacity: 100];
	theLock = [[NSLock alloc] init];
	return self;
}
// dealloc method
- (void) dealloc
{
	[theLock release];
	/*NSEnumerator *enm = [notifications objectEnumerator];
	NSNotification *curr = nil;
	while( (curr = [enm nextObject]) != nil)
	{
		printf("%s\n", [[curr description] UTF8String]);
	}
	printf("%i\n", [notifications count]);*/
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
	//@synchronized(notifications)
	[theLock lock];
	{
		if([notifications count])
			[notifications removeObjectAtIndex: 0];
	}
	[theLock unlock];
}
- (NSNotification *) getTop
{
	//@synchronized(notifications)
	id obj = nil;

	[theLock lock];
	{
		if([notifications count]) 
			obj = [notifications objectAtIndex: 0];
	}
	[theLock unlock];
	return obj;
}

// notifications receiver
- (void) receiveNotification: (NSNotification *)anNotification
{
	if(anNotification)
	{
		//@synchronized(notifications)
		[theLock lock];
		{
			[notifications addObject: anNotification];
		}
		[theLock unlock];
	}
}
@end


