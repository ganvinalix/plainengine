#import <MPLog.h>
#import <stdarg.h>
#import <common_defines.h>

NSString *levels[levels_count] = { @"Alert", @"Crit", @"Error", @"Warning", @"Notice", @"Inform", @"User"};

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

+ (void) load
{
	theGlobalLog = [MPLog new]; 
}

+ (MPLog *) defaultLog
{
	return theGlobalLog;
}

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

	NSUInteger i = 0;
	for(i = 0; i < levels_count; ++i)
		counts[i] = 0;
	
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

	NSString *buffer = [[[NSString alloc] initWithFormat: theFormat arguments: arglist] autorelease];

	va_end(arglist);

	NSMutableString *finalMessage = [NSMutableString stringWithCapacity: 255];
	NSMutableString *lvlStr = [NSMutableString string];
	
	if( [self isEmpty] ) return;
	
	if(theLevel >= user)
	{
		theLevel = user;
	}
	[lvlStr appendString: [MPLog getNameOfMessageLevel: theLevel]];
	++counts[theLevel];
		
	[finalMessage appendFormat: @"[%@][%@]:\t%@\n", 
		[[NSDate date] descriptionWithCalendarFormat:@"%d-%m-%Y %H:%M:%S" timeZone:nil locale: nil],
		lvlStr,
		buffer];
		
	[mutex lock];

	id <MPLogChannel> currentChannel = nil;
	NSUInteger i, count;
	count = [channels count];
	for (i = 0; i < count; ++i)
	{
		currentChannel = [channels objectAtIndex: i];
		if( ![currentChannel write: finalMessage withLevel: theLevel] )
		{
			[self removeChannel: currentChannel];
			[self add: error withFormat: @"MPLog: Dead log channel closed"];
		}
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
	{
		[mutex lock];
		[channels addObject: theChannel];
		[mutex unlock];
	}
	else
		//@throw [NSException exceptionWithName:@"Nil log channel" reason:@"Attempt to add nil like a log channel" userInfo:nil];
		return NO;
		
	if( ![theChannel isOpened] )
		if( ![theChannel open] )
		{
			[mutex lock];
			[channels removeLastObject];
			[mutex unlock];

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
	[mutex lock];

	if( ![channels containsObject: theChannel] )
	{
		[mutex unlock];
		return NO;
	}
		
	NSUInteger anObjectIdx = [channels indexOfObject: theChannel];
	[[channels objectAtIndex: anObjectIdx] close];
	[channels removeObjectAtIndex: anObjectIdx];

	[mutex unlock];
	
	return YES;
}

- (BOOL) isEmpty
{
	//printf (" channels count is: %d\n", [channels count]);
	return ([channels count] == 0);
}

- (NSUInteger) getCountOfMessagesWithLevel: (mplog_level)theLevel
{
	return counts[theLevel];
}

+ (NSString*) getNameOfMessageLevel: (mplog_level)theLevel
{
	if(theLevel >= user)
	{
		theLevel = user;
	}

	return levels[theLevel];
}
@end


