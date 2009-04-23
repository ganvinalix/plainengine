#import <MPSubjectManager.h>
#import <MPSystemSubject.h>
#import <MPThread.h>
#import <core_constants.h>

#define RUNLOOPTIMEINTERVAL 0.100

#ifdef MP_USE_EXCEPTIONS

#define MPSM_LOCK \
	[accessMutex lock];\
	@try\
	{

#define MPSM_UNLOCK \
	}\
	@finally\
	{\
		[accessMutex unlock];\
	}
#else

#define MPSM_LOCK \
	[accessMutex lock];\
	{

#define MPSM_UNLOCK \
	}\
	[accessMutex unlock];

#endif

@implementation MPSubjectManager

- (BOOL) addSubject: (id<MPSubject>)subject toThread: (unsigned)thread withName: (NSString*)name
{
	BOOL ret=YES;
	MPSM_LOCK;
	[gLog add: notice withFormat: @"MPSubjectManager: Adding subject %@ with name \"%@\"", subject, name];
	MPThread *curThread;
	NSNumber *thrnum;
	thrnum = [[NSNumber alloc] initWithUnsignedInt: thread];
	curThread = [threads objectForKey: thrnum];
	if (!curThread)
	{
		curThread = [[MPThread alloc] initWithStrategy: [MPThreadStrategy forkedStrategy] withID: thread];
		[threads setObject: curThread forKey: thrnum];
		[curThread release];
	}
	[thrnum release];
	if (![curThread addSubject: subject])
	{
		ret = NO;
	}
	[subjectToThread setObject: curThread forKey: name];
	[nameToSubject setObject: subject forKey: name];
	MPSM_UNLOCK;
	return ret;
}

- (BOOL) removeSubjectWithName: (NSString*)name
{
	BOOL ret=NO;
	MPSM_LOCK;
	if ([[subjectToThread objectForKey: name] removeSubject: [nameToSubject objectForKey: name]])
	{
		[subjectToThread removeObjectForKey: name];
		[nameToSubject removeObjectForKey: name];
		ret = YES;
	}
	MPSM_UNLOCK;
	return ret;
}

- (void) pause
{
	MPSM_LOCK;
	paused = YES;

	NSEnumerator *enumer;
	enumer = [threads keyEnumerator];
	NSNumber *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		if ([thr unsignedIntValue])
		{
				[[threads objectForKey: thr] pause];
		}
	}

	MPSM_UNLOCK;
}

- (void) resume
{
	MPSM_LOCK;
	paused = NO;
	NSEnumerator *enumer;
	enumer = [threads objectEnumerator];
	MPThread *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		[thr resume];
	}
	MPSM_UNLOCK;
}

- (void) run
{
	if (isWorking)
	{
		return;
	}
	MPSM_LOCK;
	isWorking = YES;

	NSEnumerator *enumer;
	enumer = [threads objectEnumerator];
	MPThread *thr;

	while ( (thr = [enumer nextObject]) != nil )
	{
		[thr prepare];
	}
	enumer = [threads objectEnumerator];
	while ( (thr = [enumer nextObject]) != nil )
	{
		[thr start];
	}

	MPSM_UNLOCK;
	[gLog add: notice withFormat: @"MPSubjectManager: running..."];
	while (isWorking)
	{
		if (paused)
		{
			continue;
		}
		NSDate *date = [[NSDate alloc] initWithTimeIntervalSinceNow: RUNLOOPTIMEINTERVAL];
		[[NSRunLoop currentRunLoop] runUntilDate: date];
		[date release];
	}
	[gLog add: notice withFormat: @"MPSubjectManager: stopping..."];
	MPSM_LOCK;
	NSEnumerator *enumer;

	enumer = [threads objectEnumerator];
	MPThread *th;

	while ( (th = [enumer nextObject]) != nil )
	{
		[th pause];
	}

	NSMutableArray *threadsStillUpdating = [[threads allValues] mutableCopy];
	
	BOOL correctlyTerminated=NO;
	NSUInteger waitingForUpdatesToTerminate_startTime = getMilliseconds();
	while (getMilliseconds() - waitingForUpdatesToTerminate_startTime < MPTHREAD_MAX_WAIT_FOR_UPDATE_TIME)
	{
		NSUInteger i, count=[threadsStillUpdating count];
		if (!count)
		{
			correctlyTerminated=YES;
			break; //all threads stopped updating
		}
		for (i=0; i<count; ++i)
		{
			if (![[threadsStillUpdating objectAtIndex: i] isUpdating])
			{
				[threadsStillUpdating removeObjectAtIndex: i];
				--i; //OK if i = 0
				--count;
			}
		}
	}

	if (!correctlyTerminated)
	{
		[gLog add: warning withFormat: @"MPSubjectManager: Timeout expired, but not all threads finished updating - %@;", threadsStillUpdating];
	}

	[threadsStillUpdating release];

	enumer = [threads keyEnumerator];
	NSNumber *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		if ([thr unsignedIntValue])
		{
			[gLog add: notice withFormat: @"MPSubjectManager: Trying to stop thread \"%@\"...", [threads objectForKey: thr]];
			[[threads objectForKey: thr] stop];
		}
	}
	thr = [NSNumber numberWithUnsignedInt: 0];
	[gLog add: notice withFormat: @"MPSubjectManager: Trying to stop thread \"%@\"...", [threads objectForKey: thr]];
	[[threads objectForKey: thr] stop];
	MPSM_UNLOCK;

	[gLog add: notice withFormat: @"MPSubjectManager: stopped"];
}

- (void) terminate
{
	isWorking = NO;
}

- (void) removeSubjects
{
	NSAutoreleasePool *pool = [MPAutoreleasePool new];
	id name;
	NSArray *subjectNames = [nameToSubject allKeys];

	NSEnumerator *enumer = nil;
	enumer = [subjectNames objectEnumerator];
	while ((name = [enumer nextObject]) != nil)
	{
		[self removeSubjectWithName: name];
	}
	[pool release];
}

- init
{
	[super init];
	paused = NO;
	isWorking = NO;
	threads = [NSMutableDictionary new];
	subjectToThread = [NSMutableDictionary new];
	nameToSubject = [NSMutableDictionary new];
	accessMutex = [NSLock new];
	
	MPThread *mainThread;
	NSNumber *threadNum;
	threadNum = [[NSNumber alloc] initWithUnsignedInt: 0];
	mainThread = [[MPThread alloc] initWithStrategy: [MPThreadStrategy subroutineStrategy] withID: 0];
	MPSM_LOCK;
	id<MPSubject> syssubj;
	syssubj = [[MPSystemSubject alloc] initWithSubjectManager: self]; 
	[mainThread addSubject: syssubj];
	[threads setObject: mainThread forKey: threadNum];
	[subjectToThread setObject: mainThread forKey: MPSystemSubjectName];
	[syssubj release];
	MPSM_UNLOCK;

	[threadNum release];


	return self;
}

- (void) dealloc
{
	[accessMutex release];
	[threads release];
	[nameToSubject release];
	[subjectToThread release];
	[super dealloc];
}

+ (id) subjectManager
{
	return [[[MPSubjectManager alloc] init] autorelease];
}

@end

