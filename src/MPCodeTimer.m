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

+ (void) load
{
	timersData = [[NSMutableDictionary alloc] initWithCapacity: 10];
	//timersData would exist ALWAYS. So, we don't need to release or autorelease it
	//More than that, autorelease pool even doesn't still exist
}

- init
{
	return [self initWithSectionByName: @"default"];
}

- (void) dealloc
{
	[timerData release];
	[super dealloc];
}

- (id) initWithSectionByName: (NSString*)sectionName
{
	[super init];
	//create timersData dictionary at first run
	//if(timersData == nil)
	//{
	//	timersData = [NSMutableDictionary dictionaryWithCapacity: 10];
	//}
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

	statistics.totalTimeUnfinished=0;
	statistics.totalCallsUnfinished=0;
	statistics.minTimeSampleUnfinished=0;
	statistics.maxTimeSampleUnfinished=0;
	statistics.averageTimeUnfinished=0;

	//if (!timersData)
	//{
	//	return statistics; //quit when timersData is not created;
	//}
	
	
	//To be sure that the last session is closed:
	MPTimerData *aTimerData;
	NSMutableArray *aSection;
	aSection = [timersData objectForKey: sectionName]; 
	if ([aSection count])
	{
		aTimerData = [aSection lastObject];
		if (![aTimerData isFinished])
		{
			aTimerData->finishTime = [[NSDate date] timeIntervalSince1970];
		}
	}


	BOOL b=YES; //Flag, which shows, is it first iteration or not.
	//It's neccesary for finding minimum of time without perversion :)
	NSEnumerator *enumerator = [[timersData objectForKey: sectionName] objectEnumerator];
	MPTimerData *td;

	while ( (td = [enumerator nextObject]) != nil )
	{
		int ct = (td->finishTime - td->startTime)*1000; //conversion from double here.
		//ct - current session time in ms;
	
		unsigned *aTotalCalls,
			 *aTotalTime,
			 *aMinTimeSample,
			 *aMaxTimeSample;

		if ([td isFinished])
		{
			aTotalCalls	= &(statistics.totalCalls);
			aTotalTime	= &(statistics.totalTime);
			aMinTimeSample	= &(statistics.minTimeSample);
			aMaxTimeSample	= &(statistics.maxTimeSample);
		}
		else
		{
			aTotalCalls	= &(statistics.totalCallsUnfinished);
			aTotalTime	= &(statistics.totalTimeUnfinished);
			aMinTimeSample	= &(statistics.minTimeSampleUnfinished);
			aMaxTimeSample	= &(statistics.maxTimeSampleUnfinished);
		}
		++(*aTotalCalls);
		(*aTotalTime) += ct;
		if (b)
		{
			(*aMinTimeSample) = ct;
			(*aMaxTimeSample) = ct;
			b = NO;
		}
		else
		{
			if (ct < (*aMinTimeSample))
			{
				(*aMinTimeSample) = ct;
			}
			if (ct > (*aMaxTimeSample))
			{
				(*aMaxTimeSample) = ct;
			}
		};
	}
	if (statistics.totalTime) //Without division by zero; // yes, good boy ;D
	{
		statistics.averageTime = statistics.totalTime / statistics.totalCalls;
	}

	if (statistics.totalTimeUnfinished)
	{
		statistics.averageTimeUnfinished = statistics.totalTimeUnfinished / statistics.totalCallsUnfinished;
	}

	return statistics;
}

+ (NSString *) printStatisticsByName: (NSString*)sectionName
{
	NSMutableString *str;
	str = [NSMutableString stringWithCapacity: 225];
	ProfilingStatistics statistics;
	statistics = [self getStatisticsByName: sectionName];
	[str appendFormat: @"Code timer statistics for \"%@\":\n", sectionName];
	[str appendFormat: @"Total calls: %d (%d - unfinished sessions) \nTotal time: %d (%d - unfinished sessions) \nMaximum time: %d (%d - unfinished sessions) \nMinimum time: %d (%d - unfinished sessions) \nAverage time: %d (%d - unfinished sessions) \n",
		statistics.totalCalls,
		statistics.totalCallsUnfinished,
		statistics.totalTime,
		statistics.totalTimeUnfinished,
		statistics.maxTimeSample,
		statistics.maxTimeSampleUnfinished,
		statistics.minTimeSample,
		statistics.minTimeSampleUnfinished,
		statistics.averageTime,
		statistics.averageTimeUnfinished
		];
	return str;
}

- (void) beginSession
{
	MPTimerData *aTimerData;
	if ([timerData count])
	{
		aTimerData = [timerData lastObject];
		if (![aTimerData isFinished])
		{
			aTimerData->finishTime = [[NSDate date] timeIntervalSince1970];
		}
	}
	aTimerData = [[[MPTimerData alloc] init] autorelease];
	aTimerData->startTime = [[NSDate date]  timeIntervalSince1970];
	//[self endSession]; //To be sure that the last session is closed;
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

