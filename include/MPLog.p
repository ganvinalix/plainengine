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

/** Log protocol */
@protocol  MPLog < NSObject >
/** Adds a message with a specified level */
- (void) add: (mplog_level)theLevel withFormat: (NSString *)theFormat, ...;
/** Returns a count of messages with a specified level */
- (NSUInteger) getCountOfMessagesWithLevel: (mplog_level)theLevel;
/** Returns the name of a message level */
+ (NSString*) getNameOfMessageLevel: (mplog_level)theLevel;
@end

