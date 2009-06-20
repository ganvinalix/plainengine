#import <MPProfiling.h>
#import <MPUtility.h>


/** Fills MPProfilingStatistics structure with the initial values */
void MPInitProfiling(MPProfilingStatistics *stats)
{
	if(!stats)
		return;

	memset(stats, 0, sizeof(MPProfilingStatistics));
}

void MPBeginProfiligSession(MPProfilingStatistics *stats)
{
	if(!stats)
		return;

	NSUInteger currentTime = getMilliseconds();

	// if previous session is unfinished
	if(stats->lastTime != 0) 
	{
		NSUInteger currentSample = (currentTime - stats->lastTime);
		stats->totalCallsUnfinished++;
		stats->totalTimeUnfinished += currentSample;

		if(currentSample > stats->maxTimeSampleUnfinished)
			stats->maxTimeSampleUnfinished = currentSample;

		if(currentSample < stats->minTimeSampleUnfinished)
			stats->minTimeSampleUnfinished = currentSample;

		stats->averageTimeUnfinished = 
			(float) stats->totalTimeUnfinished / stats->totalCallsUnfinished;
	}
	stats->lastTime = currentTime;
}

void MPEndProfiligSession(MPProfilingStatistics *stats)
{
	if(!stats)
		return;
	
	NSUInteger currentTime = getMilliseconds();
	NSUInteger currentSample = (currentTime - stats->lastTime);

	stats->totalCalls++;
	stats->totalTime += currentSample;

	if(currentSample > stats->maxTimeSample)
		stats->maxTimeSample= currentSample;

	if(currentSample < stats->minTimeSample)
		stats->minTimeSample= currentSample;

	stats->averageTime = (float) stats->totalTime/ stats->totalCalls;
	stats->lastTime = 0; // Mark session as finished
}

NSString *MPPrintProfilingStatistics(MPProfilingStatistics *stats)
{
	if(!stats)
		return @"";

	NSMutableString *str = [NSMutableString stringWithCapacity: 225];

	//[str appendFormat: @"Code timer statistics for \"%@\":\n", sectionName];
	[str appendFormat: @"Total calls: %d (%d - unfinished sessions) \nTotal time: %d (%d - unfinished sessions) \nMaximum time: %d (%d - unfinished sessions) \nMinimum time: %d (%d - unfinished sessions) \nAverage time: %f (%f - unfinished sessions) \n",
		stats->totalCalls,
		stats->totalCallsUnfinished,
		stats->totalTime,
		stats->totalTimeUnfinished,
		stats->maxTimeSample,
		stats->maxTimeSampleUnfinished,
		stats->minTimeSample,
		stats->minTimeSampleUnfinished,
		stats->averageTime,
		stats->averageTimeUnfinished
		];

	return str;

}


