#import <Foundation/Foundation.h>

typedef struct
{
	unsigned totalTime;
	unsigned totalCalls;
	unsigned maxTimeSample;
	unsigned minTimeSample;
	unsigned averageTime;

	unsigned totalTimeUnfinished;
	unsigned totalCallsUnfinished;
	unsigned maxTimeSampleUnfinished;
	unsigned minTimeSampleUnfinished;
	unsigned averageTimeUnfinished;
} ProfilingStatistics;

@interface MPCodeTimer : NSObject 
{
@private
	NSMutableArray* timerData;
}
- init;
- (id) initWithSectionByName: (NSString*)sectionName;
- (void) dealloc;

+ (id) codeTimer;
+ (id) codeTimerWithSectionName: (NSString*)sectionName;

+ (ProfilingStatistics) getStatisticsByName: (NSString*)sectionName;
+ (NSString*) printStatisticsByName: (NSString*)sectionName;

- (void) beginSession;
- (void) endSession;
@end

