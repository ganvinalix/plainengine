#import <MPCore.h>

@interface MPMessageAnnouncerSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	NSMutableArray *banned;
}
MP_HANDLER_OF_ANY_MESSAGE;
@end


