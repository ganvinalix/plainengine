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
		timer = [MPCodeTimer codeTimerWithSectionName: @"test"];
		timercopy = [[MPCodeTimer alloc] initWithSectionByName: @"test"];
		megatimer = [MPCodeTimer codeTimerWithSectionName: @"mega"];
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
		}
		[timercopy release];

		timer2 = [MPCodeTimer codeTimerWithSectionName: @"qq"];
		[timer2 beginSession];
		MP_SLEEP(38);
		[timer2 endSession];

		[megatimer endSession];
		[gLog add: notice withFormat: [MPCodeTimer printStatisticsByName: @"test"]];
		[gLog add: notice withFormat: [MPCodeTimer printStatisticsByName: @"mega"]];
		[gLog add: notice withFormat: [MPCodeTimer printStatisticsByName: @"qq"]];
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

