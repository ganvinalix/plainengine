#import <common.h>
#import <MPObject.h>
#import <math.h>

int main(int argc, const char *argv[]) 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try
	{

		[gLog addChannel: [MPFileLogChannel fileLogChannelWithFilename: @"./hist.log"]];
		[gLog add: notice withFormat: @"Startting..."];
		
		MPMutableDictionary *dict;
		dict = [[MPMutableDictionary alloc] init];
		
		[dict setObject: @"btest" forKey: @"test"];
		[dict setObject: @"btast" forKey: @"tast"];
		[dict setObject: @"btbst" forKey: @"tbst"];
		[dict setObject: @"btcst" forKey: @"tcst"];
		
		NSEnumerator *enumer;
		NSString *str;

		MP_BEGIN_PROFILE(dict);
		enumer = [dict keyEnumerator];
		while ((str = [enumer nextObject]) != nil)
		{
			[gLog add: info withFormat: str];
		}
		[dict writeToFile: @"dict.txt" atomically: YES];
		MP_END_PROFILE(dict);

		[gLog add: info withFormat: [MPCodeTimer printStatisticsByName: @"dict"]];
	}
	@catch(NSException *exc)
	{
		[gLog add: alert withFormat: @"An exception caught: %@ \n %@", [exc name], [exc reason]];
	}
	@finally
	{
		[gLog add: notice withFormat:@"End."];
		[pool release];
	}
	return 0;
}

