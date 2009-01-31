#import <Foundation/Foundation.h>
#import <MPLog.p>

/** Log channel protocol */
@protocol MPLogChannel < NSObject >
/** Opens a log channel */
- (BOOL) open;
/** Returns YES if it's already opened */
- (BOOL) isOpened;
/** Closes a log channel */
- (void) close;
/** Adds a message to a channel */
- (BOOL) write: (NSString *)theMessage withLevel: (mplog_level)theLevel;
@end

/** Global log */
@interface MPLog : NSObject < MPLog >
{
@private
	NSMutableArray *channels;
	NSLock *mutex;
}
/** Adds a log channel (just retains theChannel) */
- (BOOL) addChannel: (id <MPLogChannel>)theChannel;
/** Removes a log channel */
- (BOOL) removeChannel: (id <MPLogChannel>)theChannel;

/** Cleanup */
- (void) cleanup;

/** Returns YES if there are no channels in manager */
- (BOOL) isEmpty;
/** Get new log */
+ (MPLog *) log;
/** Iinitializes this */
- init;
/** Deallocates reciever */
- (void) dealloc;
@end

#ifndef _INSIDE_LOG_M
extern MPLog *theGlobalLog;
#define gLog theGlobalLog
#endif
