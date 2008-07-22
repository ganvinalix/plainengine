#import <Foundation/Foundation.h>
#import <stdio.h>
#import <stdlib.h>

#import <MPLog.h>

// file log channel
@interface MPFileLogChannel : NSObject < MPLogChannel >
{
@private
	FILE *file;
	NSString *filename;
}
- init;
- initWithFilename: (NSString *)theFilename;
- (void) dealloc;

+ fileLogChannel;
+ fileLogChannelWithFilename: (NSString *)theFilename;
@end

