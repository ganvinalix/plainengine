#import <MPSubjectManager.h>
#import <MPSystemSubject.h>
#import <MPThread.h>
#import <core_constants.h>

#define RUNLOOPTIMEINTERVAL 0.050

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

#define MPSM_LOCK [accessMutex lock];
#define MPSM_UNLOCK [accessMutex unlock];

#endif

@implementation MPSubjectManager

- (BOOL) addSubject: (id<MPSubject>)subject toThread: (unsigned)thread withName: (NSString*)name
{
	BOOL ret=YES;
	MPSM_LOCK;
	MPThread *curThread;
	NSNumber *thrnum;
	thrnum = [[NSNumber alloc] initWithUnsignedInt: thread];
	curThread = [threads objectForKey: thrnum];
	if (!curThread)
	{
		curThread = [[MPThread alloc] initWithStrategy: [MPThreadStrategy forkedStrategy]];
		[threads setObject: curThread forKey: thrnum];
		[curThread release];
	}
	[thrnum release];
	if (![curThread addSubject: subject withName: name])
	{
		ret = NO;
	}
	[subjectToThread setObject: curThread forKey: name];
	MPSM_UNLOCK;
	return ret;
}

- (BOOL) removeSubjectWithName: (NSString*)name
{
	BOOL ret=NO;
	MPSM_LOCK;
	if ([[subjectToThread objectForKey: name] removeSubjectWithName: name])
	{
		[subjectToThread removeObjectForKey: name];
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

	/*
	NSEnumerator *enumer;
	enumer = [threads objectEnumerator];
	MPThread *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		[thr pause];
	}
	*/
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
	[gLog add: notice withFormat: @"MPSubjectManager: stopped"];
}

- (void) terminate
{
	[gLog add: notice withFormat: @"MPSubjectManager: stopping..."];
	MPSM_LOCK;
	isWorking = NO;
	NSEnumerator *enumer;
	enumer = [threads keyEnumerator];
	NSNumber *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		if ([thr unsignedIntValue])
		{
			[[threads objectForKey: thr] stop];
		}
	}
	[[threads objectForKey: [NSNumber numberWithUnsignedInt: 0]] stop];
	MPSM_UNLOCK;
}

- init
{
	[super init];
	paused = NO;
	isWorking = NO;
	threads = [[NSMutableDictionary alloc] init];
	subjectToThread = [[NSMutableDictionary alloc] init];
	accessMutex = [[NSLock alloc] init];
	
	MPThread *mainThread;
	NSNumber *thrnum;
	thrnum = [[NSNumber alloc] initWithUnsignedInt: 0];
	mainThread = [[MPThread alloc] initWithStrategy: [MPThreadStrategy subroutineStrategy]];
	MPSM_LOCK;
	id<MPSubject> syssubj;
	syssubj = [[MPSystemSubject alloc] initWithSubjectManager: self]; 
	[mainThread addSubject: syssubj withName: MPSystemSubjectName];
	[threads setObject: mainThread forKey: thrnum];
	[subjectToThread setObject: mainThread forKey: MPSystemSubjectName];
	[syssubj release];
	MPSM_UNLOCK;

	[thrnum release];


	return self;
}

- (void) dealloc
{
	
	/*
	NSEnumerator *enumer;
	enumer = [threads objectEnumerator];
	MPThread *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		[thr release];
	}
	*/
	[accessMutex release];
	[threads release];
	[subjectToThread release];
	[super dealloc];
}

+ (id) subjectManager
{
	return [[[MPSubjectManager alloc] init] autorelease];
}

@end

