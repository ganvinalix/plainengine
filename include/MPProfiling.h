#import <Foundation/Foundation.h>

/** Structure with MPCodeTimer section statistics */
typedef struct
{
	/** Total time spent on executing current section code (successfully finished sessions)*/
	NSUInteger totalTime;
	/** totalTime - Number of sessions started and finished successfully */
	NSUInteger totalCalls;
	/** totalCall - Maximum time spent on executing one session code (successfully finished sessions)*/
	NSUInteger maxTimeSample;
	/** maxTimeSample - Minimum time spent on executing one session code (successfully finished sessions)*/
	NSUInteger minTimeSample;
	/** minTimeSample - Average time spent on executing one session code (successfully finished sessions)*/
	float averageTime;

	/** totalTimeUnfinished - Total time spent on executing current section code (not finished sessions)*/
	NSUInteger totalTimeUnfinished;
	/** totalCallsUnfinished - Number of sessions started but didn't finished by endSession method */
	NSUInteger totalCallsUnfinished;
	/** maxTimeSampleUnfinished - Maximum time spent on executing one session code (unfinished sessions)*/
	NSUInteger maxTimeSampleUnfinished;
	/** minTimeSampleUnfinished - Minimum time spent on executing one session code (unfinished sessions)*/
	NSUInteger minTimeSampleUnfinished;
	/** averageTimeUnfinished - Average time spent on executing one session code (unfinished sessions)*/
	float averageTimeUnfinished;

	/** lastTime - Zero or time of a current session */
	NSUInteger lastTime;
} MPProfilingStatistics;

void MPInitProfiling(MPProfilingStatistics *stats);
void MPBeginProfilingSession(MPProfilingStatistics *stats);
void MPEndProfilingSession(MPProfilingStatistics *stats);
NSString *MPPrintProfilingStatistics(MPProfilingStatistics *stats);

