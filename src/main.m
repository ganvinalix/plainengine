#import <common.h>
#import <MPObject.h>
#import <MPCodeTimer.h>
#import <MPDictionary.h>
#import <math.h>

int main(int argc, const char *argv[]) 
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	@try
	{
		/*MPCodeTimer *megatimer;
		megatimer = [MPCodeTimer codeTimerWithSectionName: @"mega"];
		[megatimer beginSession];*/

		[gLog addChannel: [MPFileLogChannel fileLogChannelWithFilename: @"./hist.log"]];
		[gLog add: notice withFormat: @"Startting..."];
		
		/*
		long long int s;
		int i, j;
		
		MPCodeTimer *timer, *timercopy, *timer2;
		timer = [MPCodeTimer codeTimerWithSectionName: @"test"];
		timercopy = [[MPCodeTimer alloc] initWithSectionByName: @"test"];
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
				s += sqrt(i);
			}
			[timercopy endSession];
		}
		[timercopy release];

		timer2 = [MPCodeTimer codeTimerWithSectionName: @"qq"];
		[timer2 beginSession];
		MP_SLEEP(38);
		[timer2 endSession];

		MPCodeTimer *logtimer;
		logtimer = [MPCodeTimer codeTimerWithSectionName: @"log"];

		[logtimer beginSession];
		[gLog add: info withFormat: [MPCodeTimer printStatisticsByName: @"test"]];
		[gLog add: info withFormat: [MPCodeTimer printStatisticsByName: @"qq"]];
		[logtimer endSession];
		[gLog add: info withFormat: [MPCodeTimer printStatisticsByName: @"log"]];

		//MPCodeTimer *tt;
		//tt = [MPCodeTimer codeTimerWithSectionName: @"tt"];
		*/
		MPMutableDictionary *dict;
		dict = [[MPMutableDictionary alloc] init];
		
		[dict setObject: @"btest" forKey: @"test"];
		[dict setObject: @"btast" forKey: @"tast"];
		[dict setObject: @"btbst" forKey: @"tbst"];
		[dict setObject: @"btcst" forKey: @"tcst"];
		
		NSEnumerator *enumer;
		NSString *str;
		CT_BEGIN(dict);
		enumer = [dict keyEnumerator];
		while ((str = [enumer nextObject]) != nil)
		{
			[gLog add: info withFormat: str];
		}
		[dict writeToFile: @"dict.txt" atomically: YES];

		CT_END(dict);

		[gLog add: info withFormat: [MPCodeTimer printStatisticsByName: @"dict"]];
		/*
		[megatimer endSession];
		[gLog add: info withFormat: [MPCodeTimer printStatisticsByName: @"mega"]];
		*/
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

