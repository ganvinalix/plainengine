#import <MPCore.h>
#import <irrlicht.h>


@interface MPIrrlichtRenderSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	id log,	objSys;

	NSUInteger winWidth, winHeight, winBpp;
	irr::video::E_DRIVER_TYPE winDriverType;
	BOOL winFullscreen;
	BOOL winShowCursor;
	NSString *winCaption;

	irr::IrrlichtDevice *device;
	irr::video::IVideoDriver *driver;
	irr::scene::ISceneManager *smgr;
	irr::gui::IGUIEnvironment *guienv;
}

- (BOOL) isFullscreen;

- (BOOL) isCursorVisible;
- (void) showCursor: (BOOL)show;

- (NSSize) getWindowSize;

MP_HANDLER_OF_MESSAGE(showCursor);
@end
