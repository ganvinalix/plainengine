#import <Foundation/Foundation.h>

// names of levels
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

@protocol MPLogChannel < NSObject >
// opens a log channel
- (BOOL) open;
// returns YES if it's already opened
- (BOOL) isOpened;
// closes a log channel
- (void) close;
// adds a message to a channel
- (BOOL) write: (NSString *)theMessage withLevel: (mplog_level)theLevel;
@end

@protocol  MPLog < NSObject >
// adds a message with a specified level
- (void) add: (mplog_level)theLevel withFormat: (NSString *)theFormat, ...;

// adds a log channel (just retains theChannel)
- (BOOL) addChannel: (id <MPLogChannel>)theChannel;
// removes a log channel
- (BOOL) removeChannel: (id <MPLogChannel>)theChannel;

// cleanup
- (void) cleanup;

// returns YES if there are no channels in manager
- (BOOL) isEmpty;
// get current log
+ (id <MPLog>) log;
@end

@interface MPLog : NSObject < MPLog >
{
@private
	NSMutableArray *channels;
}
// consructor / destructor
- init;
- (void) dealloc;
@end

// Macroses for quick handling
#define gLog		[MPLog log] 


