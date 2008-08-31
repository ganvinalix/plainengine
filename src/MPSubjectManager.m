#import <MPSubjectManager.h>

#define RUNLOOPTIMEINTERVAL 0.050

@implementation MPSubjectManager

- (BOOL) addSubject: (id<MPSubject>)subject toThread: (NSUInteger)thread withName: (NSString*)name
{
	MPThread *curThread;
	curThread = [threads objectAtIndex: thread];
	if (!curThread)
	{
		curThread = [[MPThread alloc] init];
		[accessMutex lock];
		@try
		{
			[threads insertObject: curThread atIndex: thread];
		}
		@finally
		{
			[accessMutex unlock];
		}
	}
	if (![curThread addSubject: subject withName: name])
	{
		return NO;
	}
	[accessMutex lock];
	@try
	{
		[subjectToThread setObject: curThread forKey: name];
	}
	@finally
	{
		[accessMutex unlock];
	}
	return YES;
}

- (BOOL) removeSubjectWithName: (NSString*)name
{
	if ([[subjectToThread objectForKey: name] removeSubjectWithName: name])
	{
		[accessMutex lock];
		@try
		{
			[subjectToThread removeObjectForKey: name];
		}
		@finally
		{
			[accessMutex unlock];
		}
		return YES;
	}
	return NO;
}

- (void) pause
{
	[accessMutex lock];
	@try
	{
		paused = YES;
		NSEnumerator *enumer;
		enumer = [threads objectEnumerator];
		MPThread *thr;
		while ( (thr = [enumer nextObject]) != nil )
		{
			[thr pause];
		}
	}
	@finally
	{
		[accessMutex unlock];
	}
}

- (void) resume
{
	[accessMutex lock];
	@try
	{
		paused = NO;
		NSEnumerator *enumer;
		enumer = [threads objectEnumerator];
		MPThread *thr;
		while ( (thr = [enumer nextObject]) != nil )
		{
			[thr resume];
		}
	}
	@finally
	{
		[accessMutex unlock];
	}
}

- (void) run
{
	if (isWorking)
	{
		return;
	}
	[accessMutex lock];
	isWorking = YES;
	[accessMutex unlock];
	while (isWorking)
	{
		if (paused)
		{
			continue;
		}
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: RUNLOOPTIMEINTERVAL]];
	}
}

- (void) terminate
{
	[accessMutex lock];
	@try
	{
		isWorking = NO;
		NSEnumerator *enumer;
		enumer = [threads objectEnumerator];
		MPThread *thr;
		while ( (thr = [enumer nextObject]) != nil )
		{
			[thr stop];
		}
	}
	@finally
	{
		[accessMutex unlock];
	}
}

- init
{
	[super init];
	paused = NO;
	isWorking = NO;
	threads = [[NSMutableArray alloc] init];
	subjectToThread = [[NSMutableDictionary alloc] init];
	accessMutex = [[NSLock alloc] init];
	return self;
}

- (void) dealloc
{
	
	NSEnumerator *enumer;
	enumer = [threads objectEnumerator];
	MPThread *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		[thr release];
	}

	[subjectToThread removeAllObjects];

	[accessMutex release];
	[threads release];
	[subjectToThread release];
	[super release];
}

+ (id) subjectManager
{
	return [[[MPSubjectManager alloc] init] autorelease];
}

@end

