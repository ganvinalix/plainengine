#import <Foundation/Foundation.h>

#import <common.h>
#import <core_constants.h>

#import <MPLinker.h>

#define MP_ADDSUBJECT(manager, subject, thread) \
	[manager addSubject: [[[subject alloc] init] autorelease] toThread: thread withName: @#subject];

int main(int argc, const char *argv[]) 
{
	theGlobalLog = [MPLog new]; 
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	MPSubjectManager *subjman = nil;
	id descriptions = nil, state = nil;

	#ifdef MP_USE_EXCEPTIONS
	@try
	{
	#endif
		[gLog addChannel: [MPFileLogChannel fileLogChannelWithFilename: @"./hist.log"]];
		[gLog add: notice withFormat: @"Starting..."];

		subjman = [[MPSubjectManager alloc] init];

		[gLog add: notice withFormat: @"Parsing linker config..."];
		descriptions = MPParseLinkerConfig([NSString stringWithContentsOfFile: @"subjects.conf"]);
		[gLog add: notice withFormat: @"Parsing complete"];

		[gLog add: notice withFormat: @"Linking..."];
		state = MPLinkModules(descriptions, subjman);
		[gLog add: notice withFormat: @"Linking complete"];

		MPAutoreleasePool *runPool = [MPAutoreleasePool new];
		
		if(state != nil)
			[subjman run];

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
		[subjman release];
		MPUnloadModules(state);
		[pool release];

		[gLog add: notice withFormat:@"End."];

		[theGlobalLog release];

	}
	return 0;
}

