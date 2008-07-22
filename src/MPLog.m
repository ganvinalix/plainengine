#import <MPLog.h>
#import <stdarg.h>

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
	if( theGlobalLog != nil ) 
	{
		if(self != theGlobalLog) [self release];
		return [theGlobalLog retain];
	}
	
	[super init];
	
	channels = [[NSMutableArray alloc] initWithCapacity: 20];
	
	id <MPLogChannel> anDefChannel = [[MPDefaultLogChannel alloc] init];
	[self addChannel: anDefChannel];
	[anDefChannel release];
	
	theGlobalLog = self; 
	return theGlobalLog;
}
- (void) dealloc
{
	[self cleanup];
	[channels release];
	
	[super dealloc];
}
// MPLog protocol implementation
+ (id <MPLog>) log
{
	if(theGlobalLog != nil) return theGlobalLog;
	
	return [[[MPLog alloc] init] autorelease];
}
- (void) add: (mplog_level)theLevel withFormat: (NSString *)theFormat, ...;
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	[[theFormat retain] autorelease];
	
	BOOL error = NO;
	NSMutableString *finalMessage = [NSMutableString stringWithCapacity: 255];
	NSMutableString *lvlStr = [NSMutableString string];
	
	va_list arglist;
	va_start(arglist, theFormat);
	//
	char buffer[4096];
	vsprintf( (char*)&buffer, [theFormat UTF8String], arglist);
	va_end(arglist);
	
	NSString *levels[] = { @"Alert", @"Crit", @"Error", @"Warning", @"Notice", @"Inform" };
	
	if( [self isEmpty] ) return;
	
	if(theLevel >= user)
		[lvlStr appendString: @"User"];
	else
		[lvlStr appendString: levels[theLevel]];
		
	[finalMessage appendFormat: @"[%@][%@]:\t%s\n", 
		[[NSDate date] descriptionWithCalendarFormat:@"%d-%m-%Y %H:%M:%S" timeZone:nil locale: nil],
		lvlStr,
		buffer];
		
	NSEnumerator *en = [channels objectEnumerator];
	id <MPLogChannel> currentChannel = nil;
	while( (currentChannel = [en nextObject]) != nil )
	{
		if( ![currentChannel write: finalMessage withLevel: theLevel] )
		{
			error = YES;
			[self removeChannel: currentChannel];
			break;
		}
	}
	if(error)
	{
		[self add: error withFormat: @"Dead log channel closed"];
	}
	
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
	NSEnumerator *enm = [channels objectEnumerator];
	id <MPLogChannel> currentChannel = nil;
	while( (currentChannel = [enm nextObject]) != nil )
	{
		if( [currentChannel isOpened] ) [currentChannel close];
	}
	[channels removeAllObjects];
}

- (BOOL) removeChannel: (id <MPLogChannel>)theChannel
{
	if( ![channels containsObject: theChannel] )
		return NO;
		
	unsigned anObjectIdx = [channels indexOfObject: theChannel];
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


