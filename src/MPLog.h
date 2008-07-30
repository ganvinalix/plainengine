#import <Foundation/Foundation.h>

/** Names of levels */
typedef enum 
{
	alert = 0,
	critical,
	error,
	warning,
	notice,
	info,
	user
} mplog_level;

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

/** Log protocol */
@protocol  MPLog < NSObject >
/** Adds a message with a specified level */
- (void) add: (mplog_level)theLevel withFormat: (NSString *)theFormat, ...;

/** Adds a log channel (just retains theChannel) */
- (BOOL) addChannel: (id <MPLogChannel>)theChannel;
/** Removes a log channel */
- (BOOL) removeChannel: (id <MPLogChannel>)theChannel;

/** Cleanup */
- (void) cleanup;

/** Returns YES if there are no channels in manager */
- (BOOL) isEmpty;
/** Get current log */
+ (id <MPLog>) log;
@end

/** Global log */
@interface MPLog : NSObject < MPLog >
{
@private
	NSMutableArray *channels;
}
/** Iinitializes this */
- init;
/** Deallocates reciever */
- (void) dealloc;
@end

/** Macroses for quick handling */
#define gLog		[MPLog log] 


