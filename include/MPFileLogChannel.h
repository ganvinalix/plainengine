#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>

#import <MPLog.h>

/** This class gives ability to store logs into files */
@interface MPFileLogChannel : NSObject < MPLogChannel >
{
@private
	FILE *file;
	NSString *filename;
}
/** Initializes this with filename "default.log" */
- init;
/** Initilaizes this with given filename */
- initWithFilename: (NSString *)theFilename;
/** Deallocates reciever */
- (void) dealloc;

/** "Convinience constructor" which creates file log channel to file "default.log" */
+ fileLogChannel;
/** "Convinience constructor" which creates file log channel to file with given filename */
+ fileLogChannelWithFilename: (NSString *)theFilename;
@end

