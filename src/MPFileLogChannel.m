#import <MPFileLogChannel.h>

@implementation MPFileLogChannel
- initWithFilename: (NSString *)theFilename
{
	[super init];
	file = NULL;
	filename = [[NSString alloc] initWithString: theFilename];
	return self;
}
- init
{
	return [self initWithFilename: @"./default.log"];
}
- (void) dealloc
{
	[filename release];
	[super dealloc];
}

+ fileLogChannel
{
	return [[[MPFileLogChannel alloc] init] autorelease];
}
+ fileLogChannelWithFilename: (NSString *)theFilename
{
	return [[[MPFileLogChannel alloc] initWithFilename: theFilename] autorelease];
}

// MPLogChannel implementation
- (BOOL) open 
{	
	file = fopen([filename UTF8String], "w");
	if(!file) return NO;
	
	return YES;
}
- (void) close
{
	if(file) fclose(file);
	file = NULL;
}
- (BOOL) isOpened { return file != NULL; }
- (BOOL) write: (NSString *)theMessage withLevel: (mplog_level)theLevel
{
	if(!file) return NO;
	
	fprintf(file, "%s", [theMessage UTF8String]);
	//printf("%@", theMessage);
	return YES; 
}
@end


