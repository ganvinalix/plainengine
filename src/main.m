#import <common.h>
#import <MPObject.h>
#import <MPCodeTimer.h>

int main(int argc, const char *argv[]) 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try
	{
		[gLog addChannel: [MPFileLogChannel fileLogChannelWithFilename: @"./hist.log"]];
		[gLog add: notice withFormat: @"Startting..."];
		
		//NSString *str = @"Text";
		//[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 2]];
		//[gLog add: notice withFormat: @"%@", [[NSDate date] descriptionWithCalendarFormat:@"%S-%F" timeZone:nil locale: nil]];
		//[gLog add: notice withFormat: @"%@", [[NSDate date] descriptionWithCalendarFormat:@"%S-%F" timeZone:nil locale: nil]];
		printf("%u\n", (-1) );
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

