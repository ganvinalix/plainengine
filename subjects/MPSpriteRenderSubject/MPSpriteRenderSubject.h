#import <MPCore.h>

@interface MPSpriteRenderSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	BOOL done;
	NSUInteger winWidth, winHeight, winBpp;
	BOOL winFullscreen;
	BOOL winShowCursor;
	BOOL winGrabInput;
	NSString *winCaption;
}
MP_HANDLER_OF_MESSAGE(showCursor);
MP_HANDLER_OF_MESSAGE(grabInput);
@end


