#import <MPCodeTimer.h>

//MPTimerData contains information about one timer session.
//Information about one timer section stores in NSMutableArray of MPTimerData
//And all section information stored in NSMutableDictionary named timersData;

NSMutableDictionary *timersData = nil; 

@interface MPTimerData : NSObject
{
@public
	NSTimeInterval startTime, finishTime;
	BOOL finished;
}
- init;
- (void) dealloc; 
- (BOOL) isFinished;
@end

@implementation MPTimerData
- init
{
	[super init];
	finished = NO;
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (BOOL) isFinished
{
	return finished;
}

@end


@implementation MPCodeTimer
- init
{
	return [self initWithSectionByName: @"default"];
}

- (void) dealloc
{
	[timerData release]; 
	[super dealloc];
}

- (id) initWithSectionByName: (NSString*)sectionName;
{
	[super init];
	//create timersData dictionary at first run
	if(timersData == nil)
	{
		timersData = [NSMutableDictionary dictionaryWithCapacity: 10];
	}
	NSMutableArray *aTimerData;
	aTimerData = [timersData objectForKey: sectionName];
	//aTimerData contains now info about current section.
	//Or there is still no info; then array must be created.
	if (aTimerData == nil)
	{
		aTimerData = [NSMutableArray arrayWithCapacity: 5];
		[timersData setObject: aTimerData forKey: sectionName];
	}
	timerData = [aTimerData retain]; //Timer contains only link to section info.
	//So, we wouldn't need to search for it;

	return self;
}

+ (id) codeTimer
{
	return [[[MPCodeTimer alloc] init] autorelease];
}

+ (id) codeTimerWithSectionName: (NSString *)sectionName
{
	return [[[MPCodeTimer alloc] initWithSectionByName: sectionName] autorelease];
}

+ (ProfilingStatistics) getStatisticsByName: (NSString *)sectionName
{
	ProfilingStatistics statistics;
	statistics.totalTime=0;
	statistics.totalCalls=0;
	statistics.minTimeSample=0;
	statistics.maxTimeSample=0;
	statistics.averageTime=0;
	if (!timersData)
	{
		return statistics; //quit when timersData is not created;
	}
	// [[MPCodeTimer codeTimer: sectionName] endSession]; //To be sure that the last session is closed;
	BOOL b=YES; //Flag, which shows, is it first iteration or not.
	//It's neccesary for finding minimum of time without perversion :)
	NSEnumerator *enumerator = [[timersData objectForKey: sectionName] objectEnumerator];
	MPTimerData *td;

	while ( (td = [enumerator nextObject]) != nil ) 
	{
		if (![td isFinished])
		{
			continue;
		}
		int ct = (td->finishTime - td->startTime)*1000; //conversion from double here.
		//ct - current session time in ms;
		++(statistics.totalCalls);
		statistics.totalTime += ct;
		if (b)
		{
			statistics.minTimeSample = ct;
			statistics.maxTimeSample = ct;
			b = NO;
		}
		else
		{
			if (ct < statistics.minTimeSample)
			{
				statistics.minTimeSample = ct;
			}
			if (ct > statistics.maxTimeSample)
			{
				statistics.maxTimeSample = ct;
			}
		};
	}
	if (statistics.totalCalls) //Without division by zero; // yes, good boy ;D
	{
		statistics.averageTime = statistics.totalTime / statistics.totalCalls;
	}
	return statistics;
}

+ (NSString*) printStatisticsByName: (NSString*)sectionName
{
	NSMutableString *str;
	str = [NSMutableString stringWithCapacity: 100];
	ProfilingStatistics statistics;
	statistics = [self getStatisticsByName: sectionName];
	[str appendFormat: @"Code timer statistics for \"%@\":\n", sectionName];
	[str appendFormat: @"Total calls: %d \nTotal time: %d \nMaximum time: %d \nMinimum time: %d \nAverage time: %d \n",
		statistics.totalCalls,
		statistics.totalTime,
		statistics.maxTimeSample,
		statistics.minTimeSample,
		statistics.averageTime
		];
	return str;
}

- (void) beginSession
{
	MPTimerData *aTimerData;
	aTimerData = [[[MPTimerData alloc] init] autorelease]; 
	aTimerData->startTime = [[NSDate date]  timeIntervalSince1970];
	[self endSession]; //To be sure that the last session is closed;
	[timerData addObject: aTimerData];
}

- (void) endSession
{
	if (![timerData count])
	{
		return;
	}
	MPTimerData *aTimerData;
	aTimerData = [timerData lastObject];
	if (![aTimerData isFinished])
	{
		aTimerData->finishTime = [[NSDate date] timeIntervalSince1970];
		aTimerData->finished = YES;
	}
}

@end

