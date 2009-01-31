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

/** Log protocol */
@protocol  MPLog < NSObject >
/** Adds a message with a specified level */
- (void) add: (mplog_level)theLevel withFormat: (NSString *)theFormat, ...;
@end

