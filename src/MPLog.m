#define _INSIDE_LOG_M

#import <MPLog.h>
#import <numeric_types.h>
#import <stdarg.h>
#import <common_defines.h>

// default log channel
@interface MPDefaultLogChannel : NSObject < MPLogChannel >
- init;
- (void) dealloc;

+ defaultLogChannel;
@end

@implementation MPDefaultLogChannel
- init
{
	[super init];
	//
	return self;
}
- (void) dealloc
{
	//
	[super dealloc];
}

+ defaultLogChannel
{
	return [[[MPDefaultLogChannel alloc] init] autorelease];
}

// MPLogChannel implementation
- (BOOL) open { return YES; }
- (void) close {}
- (BOOL) isOpened { return YES; }
- (BOOL) write: (NSString *)theMessage withLevel: (mplog_level)theLevel
 {
 	printf("%s", [theMessage UTF8String]);
 	return YES; 
 }
@end

// implementation of MPLog
@implementation MPLog
id <MPLog> theGlobalLog = nil;

- init
{
	/*if( theGlobalLog != nil ) 
	{
		if(self != theGlobalLog) [self release];
		return [theGlobalLog retain];
	}*/
	
	[super init];
	
	channels = [[NSMutableArray alloc] initWithCapacity: 20];
	mutex = [[NSRecursiveLock alloc] init];
	
	id <MPLogChannel> anDefChannel = [[MPDefaultLogChannel alloc] init];
	[self addChannel: anDefChannel];
	[anDefChannel release];
	
	//theGlobalLog = self; 
	return self;//theGlobalLog;
}
- (void) dealloc
{
	[self cleanup];

	[channels release];
	[mutex release];

	[super dealloc];
}
// MPLog protocol implementation
+ (MPLog *) log
{
	return [[[MPLog alloc] init] autorelease];
}
- (void) add: (mplog_level)theLevel withFormat: (NSString *)theFormat, ...;
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[[theFormat retain] autorelease];
	
	va_list arglist;
	va_start(arglist, theFormat);

	/*char buffer[4096];
	vsnprintf( (char*)&buffer, 4096, [theFormat UTF8String], arglist);*/
	//vprintf([theFormat UTF8String], arglist);
	NSString *buffer = [[[NSString alloc] initWithFormat: theFormat arguments: arglist] autorelease];

	va_end(arglist);

	BOOL error = NO;
	NSMutableString *finalMessage = [NSMutableString stringWithCapacity: 255];
	NSMutableString *lvlStr = [NSMutableString string];
	
	NSString *levels[] = { @"Alert", @"Crit", @"Error", @"Warning", @"Notice", @"Inform" };
	
	if( [self isEmpty] ) return;
	
	if(theLevel >= user)
		[lvlStr appendString: @"User"];
	else
		[lvlStr appendString: levels[theLevel]];
		
	[finalMessage appendFormat: @"[%@][%@]:\t%@\n", 
		[[NSDate date] descriptionWithCalendarFormat:@"%d-%m-%Y %H:%M:%S" timeZone:nil locale: nil],
		lvlStr,
		buffer];
		
	[mutex lock];

	id <MPLogChannel> currentChannel = nil;
	NSUInteger i, count;
	count = [channels count];
	for (i=0; i<count; ++i)
	{
		currentChannel = [channels objectAtIndex: i];
		if( ![currentChannel write: finalMessage withLevel: theLevel] )
		{
			error = YES;
			[self removeChannel: currentChannel];
			break;
		}
	}
	if(error)
	{
		[self add: error withFormat: @"MPLog: Dead log channel closed"];
	}
	
	[mutex unlock];

	[pool release];
}

- (BOOL) addChannel: (id <MPLogChannel>)theChannel
{
	// if channel already exists
	if( [channels containsObject: theChannel] ) 
		return YES;
		
	// adds log chnnel
	if(theChannel != nil)
		[channels addObject: theChannel];
	else
		//@throw [NSException exceptionWithName:@"Nil log channel" reason:@"Attempt to add nil like a log channel" userInfo:nil];
		return NO;
		
	if( ![theChannel isOpened] )
		if( ![theChannel open] )
		{
			[channels removeLastObject];
			return NO;
		}
	return YES;
}

- (void) cleanup
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	NSEnumerator *enm = [channels objectEnumerator];
	id <MPLogChannel> currentChannel = nil;
	while( (currentChannel = [enm nextObject]) != nil )
	{
		if( [currentChannel isOpened] ) [currentChannel close];
	}
	[channels removeAllObjects];
	[pool release];
}

- (BOOL) removeChannel: (id <MPLogChannel>)theChannel
{
	if( ![channels containsObject: theChannel] )
		return NO;
		
	NSUInteger anObjectIdx = [channels indexOfObject: theChannel];
	[[channels objectAtIndex: anObjectIdx] close];
	[channels removeObjectAtIndex: anObjectIdx];
	
	return YES;
}

- (BOOL) isEmpty
{
	//printf (" channels count is: %d\n", [channels count]);
	return ([channels count] == 0);
}
@end


