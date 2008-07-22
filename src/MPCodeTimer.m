#import <MPCodeTimer.h>

//MPTimerData contains information about one timer session.
//Information about one timer section stores in NSMutableArray of MPTimerData
//And all section information stored in NSMutableDictionary named timersData;

//!!! Coding style
//!!! Variable names (you give very similar names for variables, that contains MPTimerData, and NSArray of Timer data. FUCK MY BRAIN!!!)

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
	[super init];
	if(timersData == nil)
	{
		timersData = [NSMutableDictionary dictionaryWithCapacity: 1];
	}
	return self;
}

- (void) dealloc
{
	[timerData release]; //!!! makes pair with [data retain]. added by nekro.
	[super dealloc];
}

/*!!!- (id) autorelease;
{
	return [super autorelease];
}
*/
+ (id <MPCodeTimer>) codeTimer: (NSString *)sectionName
{
	//At first start - initialization of timersData;
	if (!timersData)
	{
		timersData = [NSMutableDictionary dictionaryWithCapacity: 10]; //!!! 10, not 1
	}

	NSMutableArray *data;
	data = [timersData objectForKey: sectionName];
	//data contains now info about current section.
	//Or there is still no info; then array must be created.
	if (data == nil)
	{
		data = [NSMutableArray arrayWithCapacity: 5]; //!!! why zero? 5 at least!
		[timersData setObject: data forKey: sectionName];
	}
	
	MPCodeTimer* newTimer = [[[MPCodeTimer alloc] init] autorelease];
	newTimer->timerData = [data retain]; //Timer contains only link to section info. //!!! WTF??? O_o where "retain" was?
	//So, we wouldn't need to search for it;
	return newTimer;
}

+ (ProfilingStatistics) getStats: (NSString *)sectionName
{
	[[MPCodeTimer codeTimer: sectionName] /*autorelease]*/ endSession]; //To be sure that the last session is closed; ///!!! WTF??? O_o 
	/*!!! 
		1) autorelease dosen't necessary here	
		2) you create ANOTHER timer! or not? O_o
	*/
	ProfilingStatistics statistics;
	statistics.totalTime=0;
	statistics.totalCalls=0;
	statistics.minTimeSample=0;
	statistics.maxTimeSample=0;
	statistics.averageTime=0;
	BOOL b=YES; //Flag, which shows, is it first iteration or not.
	//It's neccesary for finding minimum of time without perversion :)
	NSEnumerator *enumerator = [[timersData objectForKey: sectionName] objectEnumerator];
	MPTimerData* td;

	while ( (td = [enumerator nextObject]) != nil ) //!!! "!= nil"
	{
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
	if (statistics.totalCalls) //Without division by zero; //!!! yes, good boy ;D
	{
		statistics.averageTime = statistics.totalTime / statistics.totalCalls;
	}
	return statistics;
}

+ (void) printStats: (ProfilingStatistics)statistics
{
	printf("Total calls: %d \nTotal time: %d \nMaximum time: %d \nMinimum time: %d \nAverage time: %d \n",
		statistics.totalCalls,
		statistics.totalTime,
		statistics.maxTimeSample,
		statistics.minTimeSample,
		statistics.averageTime
		);
}

- (void) beginSession
{
	MPTimerData *data;
	data = [[[MPTimerData alloc] init] autorelease]; ///!!! autorelease
	data->startTime = [[NSDate date] /*autorelease]*/ timeIntervalSince1970];
	[self endSession]; //To be sure that the last session is closed;
	[timerData addObject: data];
}

- (void) endSession
{
	if (![timerData count])
	{
		return;
	}
	MPTimerData *data;
	data = [timerData lastObject];
	if (![data isFinished])
	{
		data->finishTime = [[NSDate date]/* autorelease]*/ timeIntervalSince1970];
		data->finished = YES;
	}
}

@end

