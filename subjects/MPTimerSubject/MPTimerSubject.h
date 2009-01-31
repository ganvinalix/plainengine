#import <MPCore.h>

/**
  This subject posts a notification strictly once per given period;
  If timer was retarded by 'retardTimer' message or by lug, notifications are post anyway;
  Initialization string:
  ms_count1 message1 message2 ... {;ms_count2 message3 ...}
  		({xxx} means that 'xxx' can be repeated as many times as you wish to (including 0 times))
		Posts message1, message2, etc. every ms_count1 milliseconds; message3, etc. every ms_count2
		Examples:
			'1000 tick' - posts message 'tick' every second
			'500 tick1 tick2' - posts messages 'tick1', 'tick2' every 500 ms.
			'300 tick1 tick2;500 tick3' - posts messages 'tick1', 'tick2' every 300 ms.; posts 'tick3' every 500 ms.
			'100 t1 t2 t3;250 t4 t5;600 t6 t7 t8 t9' - posts messages 't1', 't2', 't3' every 100 ms.;
																	  't4', 't5' every 250 ms.;
																	  't6', 't7', 't8', 't9' every 600 ms.;
  Posts messages:
  1) timerTick (relativeTime) - posted for every period of time;
  		relativeTime contains time, which was THEORETICALLY gone from subject start;
  Messages:
  1) retardTimer - retards timer, preventing it from posting notifications
  2) resumeTimer - resumes timer if it was retarded, posting all notifications which should be posted
 */
@interface MPTimerSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	//NSTimeInterval period, previousTime, startTime;
	BOOL paused;
	//NSString *messageName;
	NSMutableArray *timers;
	MPPool *dictionaryPool, *strPool;
}
MP_HANDLER_OF_MESSAGE(retardTimer);
MP_HANDLER_OF_MESSAGE(resumeTimer);
@end


