#import <Foundation/Foundation.h>
#import <MPAssertionHandler.h>

#import <common.h>
#import <core_constants.h>

#import <MPLinker.h>
#import <MPUtility.h>

#define MP_ADDSUBJECT(manager, subject, thread) \
	[manager addSubject: [[[subject alloc] init] autorelease] toThread: thread withName: @#subject];

int main(int argc, const char *argv[]) 
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	MPSubjectManager *subjman = nil;
	id descriptions = nil, state = nil;

	// set exception handler with blackjack and hookers
	MPBindAssertionHandlerToThread([NSThread currentThread]);

	#ifdef MP_USE_EXCEPTIONS
	@try
	{
	#endif

		NSString *prepConfig = MPPreprocessString( [NSString stringWithContentsOfFile: @"./startoptions.plist"], 
												 MPBuildDictionaryFromCmd(argc, argv) );
		//[prepConfig writeToFile: @"./processed.tmp" atomically: YES];
		NSData *plistData = [prepConfig dataUsingEncoding: NSUTF8StringEncoding];
		id plist = MPBuildPlistFromData(plistData);
		NSDictionary *logFileOpts = MPBuildLogOptionsFromPlist(plist);

		if( [[logFileOpts objectForKey: @"enabled"] boolValue] )
		{
			[gLog addChannel: [MPFileLogChannel fileLogChannelWithFilename: 
													[logFileOpts objectForKey: @"path"]]];
		}

		[gLog add: notice withFormat: @"Starting..."];

		subjman = [[MPSubjectManager alloc] init];

		[gLog add: notice withFormat: @"Parsing linker config..."];
		descriptions = MPBuildDescriptionsFromPlist(plist);
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
	}
	return 0;
}

