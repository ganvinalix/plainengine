#import <Foundation/Foundation.h>
#import <MPAssertionHandler.h>

#import <common.h>
#import <core_constants.h>

#import <MPLinker.h>

#define MP_ADDSUBJECT(manager, subject, thread) \
	[manager addSubject: [[[subject alloc] init] autorelease] toThread: thread withName: @#subject];

id readPlist()
{
	NSLog(@"Try to read config file.\n");
	
	NSString *error = nil;
	NSData *plistData = [NSData dataWithContentsOfFile: @"./startoptions.plist"];
	id plist = [NSPropertyListSerialization propertyListFromData: plistData
											mutabilityOption: NSPropertyListImmutable
													  format: NULL
											errorDescription: &error];
	if(!plist) 
	{
		NSLog(@"There were error: \n, %@ \n", error);
		[error release];
	}
	else 
		NSLog (@"Success.\n");
	
	BOOL valid = [plist isKindOfClass: [NSDictionary class]];
	NSCAssert(valid, @"Invalid plist structure!");
	
	if(!valid)
		plist = nil;
	
	return plist;
}

NSDictionary *buildLogOptions(id plist)
{
	// make logfile defaults
	NSDictionary *logDefaults = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: YES], @"enabled",
																			@"./hist.log", @"path", nil];
	id logOpts = [plist objectForKey: @"LogFile"];
	if(logOpts)
		NSCAssert( [logOpts isKindOfClass: [NSDictionary class]], @"Invalid plist structure!");
	
	NSDictionary *logOptsResult = MPCreateConfigDictionary(logDefaults, logOpts);
	
	return logOptsResult;
}

int main(int argc, const char *argv[]) 
{
	theGlobalLog = [MPLog new]; 
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	MPSubjectManager *subjman = nil;
	id descriptions = nil, state = nil;

	// set exception handler with blackjack and hookers
	[[[NSThread currentThread] threadDictionary] setObject: 
			 [[MPAssertionHandler new] autorelease] forKey: @"NSAssertionHandler"];

	#ifdef MP_USE_EXCEPTIONS
	@try
	{
	#endif

		id plist = readPlist();
		NSDictionary *logFileOpts = buildLogOptions(plist);

		if( [[logFileOpts objectForKey: @"enabled"] boolValue] )
		{
			[gLog addChannel: [MPFileLogChannel fileLogChannelWithFilename: 
													[logFileOpts objectForKey: @"path"]]];
		}

		[gLog add: notice withFormat: @"Starting..."];

		subjman = [[MPSubjectManager alloc] init];

		[gLog add: notice withFormat: @"Parsing linker config..."];
		descriptions = MPParseLinkerConfig([NSString stringWithContentsOfFile: @"subjects.conf"]);
		[gLog add: notice withFormat: @"Parsing complete"];

		[gLog add: notice withFormat: @"Linking..."];
		state = [MPLinkModules(descriptions, subjman) retain];
		[gLog add: notice withFormat: @"Linking complete"];

		MPAutoreleasePool *runPool = [MPAutoreleasePool new];
		
		if(state != nil)
		{
			[subjman run];
		}

		[runPool release];

	#ifdef MP_USE_EXCEPTIONS
	}
	@catch(NSException *exc)
	{
		[gLog add: alert withFormat: @"An exception caught: %@ \n %@", [exc name], [exc reason]];
	}
	@finally
	#endif
	{
		[subjman removeSubjects];
		[subjman release];

		MPUnloadModules(state);
		[state release];

		[pool release];

		[gLog add: notice withFormat: @"There were:"];

		NSUInteger level;

		for (level=0; level < levels_count; ++level)
		{
			NSUInteger msgCount;
			msgCount = [gLog getCountOfMessagesWithLevel: level];
			if (msgCount)
			{
				[gLog add: notice withFormat: @"%@\t - %lu times;", [MPLog getNameOfMessageLevel: level], msgCount];
			}
		}
		
		[gLog add: notice withFormat: @"End."];
		
		[theGlobalLog release];
	}
	return 0;
}

