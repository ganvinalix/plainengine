#import <MPCore.h>

@interface MPMessageCounterSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	NSMutableDictionary *counters;
}
MP_HANDLER_OF_ANY_MESSAGE;
@end


