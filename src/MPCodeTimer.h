#import <Foundation/Foundation.h>

typedef struct
{
	unsigned totalTime;
	unsigned totalCalls;
	unsigned maxTimeSample;
	unsigned minTimeSample;
	unsigned averageTime;
} ProfilingStatistics;

@protocol MPCodeTimer < NSObject >
+ (id <MPCodeTimer>) codeTimer: (NSString*)sectionName;
+ (ProfilingStatistics) getStatisticsByName: (NSString*)sectionName;
+ (void) printStatisticsByName: (NSString*)sectionName;

- (id) initWithSection: (NSString*)sectionName;
- (void) beginSession;
- (void) endSession;

@end

@interface MPCodeTimer : NSObject < MPCodeTimer >
{
@private
	NSMutableArray* timerData;
}
- init;
- (void) dealloc;
@end

