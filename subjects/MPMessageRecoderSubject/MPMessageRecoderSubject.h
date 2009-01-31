#import <MPCore.h>

@interface MPMessageRecoderSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	NSDictionary *recodingsDictionary;
}
MP_HANDLER_OF_ANY_MESSAGE;
@end


