#import <Foundation/Foundation.h>
#import <numeric_types.h>

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
	NSUInteger averageTime;

	/** totalTimeUnfinished - Total time spent on executing current section code (not finished sessions)*/
	NSUInteger totalTimeUnfinished;
	/** totalCallsUnfinished - Number of sessions started but didn't finished by endSession method */
	NSUInteger totalCallsUnfinished;
	/** maxTimeSampleUnfinished - Maximum time spent on executing one session code (unfinished sessions)*/
	NSUInteger maxTimeSampleUnfinished;
	/** minTimeSampleUnfinished - Minimum time spent on executing one session code (unfinished sessions)*/
	NSUInteger minTimeSampleUnfinished;
	/** averageTimeUnfinished - Average time spent on executing one session code (unfinished sessions)*/
	NSUInteger averageTimeUnfinished;
} ProfilingStatistics;

/** MPCodeTimer class helps to measure time of code section and (maybe later) gathers statistics of code execution time */
@interface MPCodeTimer : NSObject 
{
@private
	NSMutableArray* timerData;
}
+ (void) load;

/** New timer with section name "default" */
- init;
/** New timer with section name given in parameter */
- (id) initWithSectionByName: (NSString*)sectionName;
/** Deallocates reciever */
- (void) dealloc;

/** "Convinience constructor" which creates timer with section name "default" */
+ (id) codeTimer;
/** "Convinience constructor" which creates timer with section name given in parameter */
+ (id) codeTimerWithSectionName: (NSString*)sectionName;

/** Gathers code execution time statistics of section given in parameter and returns them in structure*/
+ (ProfilingStatistics) getStatisticsByName: (NSString*)sectionName;
/** Gathers code execution time statistics of section given in parameter and returns them in printable string*/
+ (NSString *) printStatisticsByName: (NSString*)sectionName;

/** Begins new session. If there is still unfinished session, marks it as "unfinished"*/
- (void) beginSession;
/** Ends current session. If there is no active sesion, does nothing*/
- (void) endSession;
@end

