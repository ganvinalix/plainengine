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
	user,
	levels_count
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
/** Returns a count of messages with a specified level */
- (NSUInteger) getCountOfMessagesWithLevel: (mplog_level)theLevel;
/** Returns the name of a message level */
+ (NSString*) getNameOfMessageLevel: (mplog_level)theLevel;
/** Adds a log channel (just retains theChannel) */
- (BOOL) addChannel: (id <MPLogChannel>)theChannel;
/** Removes a log channel */
- (BOOL) removeChannel: (id <MPLogChannel>)theChannel;
@end

