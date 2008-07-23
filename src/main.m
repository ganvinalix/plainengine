#import <common.h>
#import <MPObject.h>
#import <MPCodeTimer.h>
#import <math.h>

int main(int argc, const char *argv[]) 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try
	{
		[gLog addChannel: [MPFileLogChannel fileLogChannelWithFilename: @"./hist.log"]];
		[gLog add: notice withFormat: @"Startting..."];
		
		long long int s;
		int i, j;
		
		MPCodeTimer *timer, *timercopy, *megatimer, *timer2;
		timer = [MPCodeTimer codeTimer: @"test"];
		timercopy = [[MPCodeTimer alloc] initWithSectionByName: @"test"];
		megatimer = [MPCodeTimer codeTimer: @"mega"];
		[megatimer beginSession];
		for (j=0; j<100; ++j)
		{
			[timer beginSession];
			for (i=0; i<100*j; ++i)
			{
				s += sqrt(i);
			}
			[timer endSession];
		}
		for (j=0; j<100; ++j)
		{
			[timercopy beginSession];
			for (i=0; i<100*j; ++i)
			{
				s += sqrt(i+s);
			}
			[timercopy endSession];
		}
		[timercopy release];

		timer2 = [MPCodeTimer codeTimer: @"qq"];
		[timer2 beginSession];
		MP_SLEEP(38);
		[timer2 endSession];

		[megatimer endSession];
		[MPCodeTimer printStatisticsByName: @"test"];
		[MPCodeTimer printStatisticsByName: @"mega"];
		[MPCodeTimer printStatisticsByName: @"qq"];
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

