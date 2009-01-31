#import <MPCore.h>

@interface MPObjectPoser : NSObject <MPSubject>
{
	id <MPAPI> api;
	NSArray *featuresArray;
}
MP_HANDLER_OF_MESSAGE(consoleInput);
@end


