#import <Foundation/Foundation.h>

typedef struct
{
	unsigned totalTime;
	unsigned totalCalls;
	unsigned maxTimeSample;
	unsigned minTimeSample;
	unsigned averageTime;
} ProfilingStatistics;

@interface MPCodeTimer : NSObject 
{
@private
	NSMutableArray* timerData;
}
- init;
- (void) dealloc;

+ (id) codeTimer: (NSString*)sectionName;
+ (ProfilingStatistics) getStatisticsByName: (NSString*)sectionName;
+ (void) printStatisticsByName: (NSString*)sectionName;

- (id) initWithSectionByName: (NSString*)sectionName;
- (void) beginSession;
- (void) endSession;
@end

