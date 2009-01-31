#import <MPCore.h>

@interface MPGravityChangerSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	double X,Y,k;
}
MP_HANDLER_OF_MESSAGE(mouseButton);
@end


