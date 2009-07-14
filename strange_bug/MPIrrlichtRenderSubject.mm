#import <MPIrrlichtRenderSubject.h>
#import <MPUtility.h>
#import <cstdlib>

using namespace irr;

using namespace core;
using namespace scene;
using namespace video;
using namespace io;
using namespace gui;

E_DRIVER_TYPE getDriverTypeByName(NSString *aName)
{
	E_DRIVER_TYPE result = EDT_SOFTWARE;

	NSCAssert(aName, @"Driver name is nil!");

#define MP_DRIVER_TYPE_BY_NAME(name)\
	if( [[aName uppercaseString] isEqual: @#name] )\
	{\
		result = EDT_##name;\
	}

	MP_DRIVER_TYPE_BY_NAME(SOFTWARE);
	MP_DRIVER_TYPE_BY_NAME(OPENGL);
	MP_DRIVER_TYPE_BY_NAME(DIRECT3D8);
	MP_DRIVER_TYPE_BY_NAME(DIRECT3D9);

#undef MP_DRIVER_TYPE_BY_NAME
	return result;
}

@implementation MPIrrlichtRenderSubject

- initWithString: (NSString *)aParams
{
	[super init];

	api = nil;
	log = nil;
	objSys = nil;

	device = NULL;
	driver = NULL;
	smgr = NULL;
	guienv = NULL;

	NSDictionary *defaults = nil, *resultConf = nil, *userConf = nil;

	defaults = [[NSDictionary alloc] initWithObjectsAndKeys: @"640", @"width", @"480", @"height", @"32", @"bpp", @"NO", @"fullscreen", @"YES", @"showCursor", @"plainEngine Irrlicht render.", @"caption", @"software", @"driver", nil];

	userConf = parseParamsString(aParams);
	resultConf = MPCreateConfigDictionary(defaults, userConf);

	winWidth = [[resultConf objectForKey: @"width"] intValue];
	winHeight = [[resultConf objectForKey: @"height"] intValue];
	winFullscreen = [[resultConf objectForKey: @"fullscreen"] boolValue];
	winBpp = [[resultConf objectForKey: @"bpp"] intValue];
	winShowCursor = [[resultConf objectForKey: @"showCursor"] boolValue];
	winCaption = [[resultConf objectForKey: @"caption"] copy];
	winDriverType = getDriverTypeByName([resultConf objectForKey: @"driver"]);
 
	[defaults release];

	return self;
}

- init
{
	return [self initWithString: @""];
}

- (void) dealloc
{
	[api release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	api = [anAPI retain];
	log = [api log];
	objSys = [api getObjectSystem];
}

- (void) start
{
	[log add: notice withFormat: @"Initializing Irrlicht..."];
	device = createDevice(winDriverType, dimension2d<s32>(winWidth, winHeight), winBpp, winFullscreen, false, false, 0);
	//device = createDevice(video::EDT_OPENGL, dimension2d<s32>(640, 480), 32, false, false, false, 0);

	// start setting window caption
	unsigned len = [winCaption length]*4;
	char *buf = new char[len];

	strncpy(buf, [winCaption UTF8String], len);
	wchar_t *capt = new wchar_t[len];
	capt[len] = 0;
	mbstowcs(capt, (char *)buf, len);

	device->setWindowCaption(capt);

	delete capt;
	delete buf;
	// end %)
	
	driver = device->getVideoDriver();
	smgr = device->getSceneManager();
	guienv = device->getGUIEnvironment();
	
	[self showCursor: winShowCursor];
	device->setResizeAble(false);
	driver->setTextureCreationFlag(ETCF_ALWAYS_32_BIT, true);
	driver->setTextureCreationFlag(ETCF_CREATE_MIP_MAPS, true);


	ICameraSceneNode* cam = smgr->addCameraSceneNode(0, 
				vector3df(0, 0, 10), // position
				vector3df(0, 0, 0) //target
				);
	float aRatio = cam->getAspectRatio();
	float scale = 10.0f;
	cam->setProjectionMatrix(matrix4().buildProjectionMatrixOrthoLH(
				2*aRatio*scale, 2*scale, cam->getNearValue(), cam->getFarValue()
				), true);
	smgr->addToDeletionQueue(cam);

	IBillboardSceneNode* node = smgr->addBillboardSceneNode(0 /*parent*/);
	node->setPosition(core::vector3df(0,0,0));
	node->setSize(dimension2d<f32>(20, 20));
	node->setMaterialFlag(video::EMF_LIGHTING, false);
	node->setMaterialTexture(0, driver->getTexture("./bubble.png"));
	node->setMaterialType(EMT_TRANSPARENT_ALPHA_CHANNEL);

	[log add: notice withFormat: @"MPIrrlichtRenderSubject: initialization done"];
}

- (void) stop
{
	device->drop();
	[log add: notice withFormat: @"MPIrrlichtRenderSubject: device dropped"];
}

- (void) update
{
	if(device->run())
	{
		driver->beginScene(true, true, SColor(255,100,101,140));

		smgr->drawAll();
		guienv->drawAll();

		driver->endScene();
	}
	else
	{
		[api postMessageWithName: MPExitMessage];
	}
}
- (BOOL) isFullscreen
{
	return winFullscreen;
}

- (BOOL) isCursorVisible
{
	return winShowCursor;
}
- (void) showCursor: (BOOL)show
{
	winShowCursor = show;
	device->getCursorControl()->setVisible(winShowCursor); 
}

- (NSSize) getWindowSize
{
	NSSize size;
	size.width = winWidth;
	size.height = winHeight;

	return size;
}

MP_HANDLER_OF_MESSAGE(showCursor)
{
	[self showCursor: [[MP_MESSAGE_DATA objectForKey: @"state"] boolValue]];
}

@end

