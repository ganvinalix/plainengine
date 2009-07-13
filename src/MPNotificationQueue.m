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
	[notifications release];
	[super dealloc];
}

// factory method
+ notificationQueue
{
	return [[[MPNotificationQueue alloc] init] autorelease];
}

// accessors 

// Maximum loops in spin lock
#define MPSPINLOCK_MAX_LOOPS_COUNT 10
#define MPSPINLOCK_LOCK(alock) \
	NSUInteger i##alock = 0; \
	BOOL success##alock = NO; \
	do { \
		success##alock = [alock tryLock]; \
		++i##alock; \
	} while( !success##alock && (i##alock < MPSPINLOCK_MAX_LOOPS_COUNT) );\
	if(!success##alock) {\
		[alock lock]; \
	}

	//while( [alock tryLock] );

- (void) popTop
{
	MPSPINLOCK_LOCK(theLock);
	if([notifications count])
		[notifications removeObjectAtIndex: 0];
	[theLock unlock];
}
- (NSNotification *) getTop
{
	id obj = nil;

	MPSPINLOCK_LOCK(theLock);
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
		MPSPINLOCK_LOCK(theLock);
		[notifications addObject: anNotification];
		[theLock unlock];
	}
}

#undef MPSPINLOCK_LOCK
#undef MPSPINLOCK_MAX_LOOPS_COUNT

- (NSString*) description
{
	return [notifications description];
}
@end


