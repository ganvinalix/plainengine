#import <Foundation/Foundation.h>
#import <MPLog.p>

/** Log */
@interface MPLog : NSObject < MPLog >
{
@private
	NSMutableArray *channels;
	NSLock *mutex;
	NSUInteger counts[levels_count];
}
/** Cleanup */
- (void) cleanup;

/** Returns default log */
+ (MPLog *) defaultLog;

/** Returns YES if there are no channels in manager */
- (BOOL) isEmpty;
/** Get new log */
+ (MPLog *) log;
/** Iinitializes this */
- init;
/** Deallocates reciever */
- (void) dealloc;
@end

#define gLog [MPLog defaultLog]
