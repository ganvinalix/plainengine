#import <MPSpriteRenderSubject.h>
#import <MPSpriteRenderDelegate.h>
#import <MPRenderable.h>
#import <MPCamera.h>

#import <SDL.h>
#import <GL/gl.h>
#import <GL/glu.h>

#import <IL/ilut.h>

#define log [api log]

float aspectRatio = 1.3;

void convertMouseCoordinates(int x, int y, unsigned screenWidh, unsigned screenHeigth, double *dx, double *dy)
{
	*dx = 2.0*aspectRatio*((double)x/screenWidh - 0.5);
	*dy = 2.0*((double)y/screenHeigth -0.5);
	*dy *= -1.0;
}

void showCursor(BOOL show)
{
	int toggle = 0;
	if(show)
	{
		toggle = SDL_ENABLE;
	}
	else
	{
		toggle = SDL_DISABLE;
	}
	SDL_ShowCursor(toggle);

}

void grabInput(BOOL grab)
{
	int toggle = 0;
	if(grab)
	{
		toggle = SDL_GRAB_ON;
	}
	else
	{
		toggle = SDL_GRAB_OFF;
	}
	SDL_WM_GrabInput(toggle);
}

@implementation MPSpriteRenderSubject
- initWithString: (NSString *)aParams
{
	[super init];

	api = nil;
	NSDictionary *defaults = nil, *userConf = nil, *resultConf = nil;
	defaults = [[NSDictionary alloc] initWithObjectsAndKeys: @"640", @"width", @"480", @"height", @"32", @"bpp", @"NO", @"fullscreen", @"YES", @"showCursor", @"NO", @"grabInput", @"plainEngine SDL-OpenGL sprite render.", @"caption", nil];

	userConf = parseParamsString(aParams);
	resultConf = MPCreateConfigDictionary(defaults, userConf);

	done = YES;

	winWidth = [[resultConf objectForKey: @"width"] intValue];
	winHeight = [[resultConf objectForKey: @"height"] intValue];
	winFullscreen = [[resultConf objectForKey: @"fullscreen"] boolValue];
	winBpp = [[resultConf objectForKey: @"bpp"] intValue];
	winShowCursor = [[resultConf objectForKey: @"showCursor"] boolValue];
	winGrabInput = [[resultConf objectForKey: @"grabInput"] boolValue];
	winCaption = [[resultConf objectForKey: @"caption"] copy];

	aspectRatio = (float)winWidth/winHeight;

	[defaults release];

	return self;
}

- init
{
	return [self initWithString: @""];
}

- (void) dealloc
{
	if (api)
	{
		[api release];
	}
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{
	[gLog add: notice withFormat: @"MPSpriteRenderSubject: Starting graphics..."];

	if( SDL_Init(SDL_INIT_VIDEO) < 0 )
	{ 
		[log add: error withFormat: @"MPSpriteRenderSubject: Unable to init SDL: %s\n", SDL_GetError()]; 
		return;
	} 

	[gLog add: notice withFormat: @"MPSpriteRenderSubject: sdl initialized"];

	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
	SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 6);
	SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);

	SDL_EnableUNICODE(1);

	Uint32 flags = SDL_OPENGL;
	if(winFullscreen)
	{
		flags |= SDL_FULLSCREEN;
	}

	[gLog add: notice withFormat: @"MPSpriteRenderSubject: setting video mod..."];
	if( SDL_SetVideoMode(winWidth, winHeight, winBpp, flags) == NULL )
	{ 
		[log add: error withFormat: @"MPSpriteRenderSubject: Unable to set %dx%d video mode: %s\n", winWidth, winHeight, SDL_GetError()]; 
		return;
	}
	SDL_EventState(SDL_MOUSEMOTION, SDL_IGNORE);
	SDL_WM_SetCaption([winCaption UTF8String], [winCaption UTF8String]);
	grabInput(winGrabInput);
	showCursor(winShowCursor);
	[gLog add: notice withFormat: @"MPSpriteRenderSubject: done"];

	ilInit();
	iluInit();
	ilutInit();
	ilutRenderer(ILUT_OPENGL);
	ilutEnable(ILUT_GL_AUTODETECT_TEXTURE_TARGET);
	ilutEnable(ILUT_OPENGL_CONV);

	glClearColor(0.0f, 0.4f, 0.6f, 0.0f);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glViewport(0, 0, winWidth, winHeight);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(-aspectRatio, aspectRatio, -1.0, 1.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	done = NO;
	[[api getObjectSystem] registerDelegate: [MPSpriteRenderDelegate class] forFeature: @"renderable"];
	[[api getObjectSystem] registerDelegate: [MPCamera class] forFeature: @"camera"];
	[log add: notice withFormat: @"MPSpriteRenderSubject: initialization done."];
}

- (void) stop
{
	grabInput(NO);
	SDL_Quit();
	[[api getObjectSystem] removeDelegate: [MPSpriteRenderDelegate class] forFeature: @"renderable"];
	[[api getObjectSystem] removeDelegate: [MPCamera class] forFeature: @"camera"];
	MP_PRINT_STATISTICS(rend);
	MP_PRINT_STATISTICS(graphics_frame);
	[log add: notice withFormat: @"MPSpriteRenderSubject: stopped."];
}

- (void) update
{
	if(done)
	{
		return;
	}

	MP_BEGIN_PROFILE(graphics_frame);
	/*[[[api getObjectSystem] getObjectByName: @"a"] moveByXY: 0.001 : 0.0];
	[[[api getObjectSystem] getObjectByName: @"a"] setRoll: 3.14/4];
	[[[api getObjectSystem] getObjectByName: @"b"] setZOrder: 10];*/
	//id b = [[api getObjectSystem] getObjectByName: @"b"];
	//[b release];

	// rendering 
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	MPCamera *camera = [[MPCamera getCamera] retain];

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	if(camera)
	{
		glTranslated(-[camera getX], -[camera getY], 0.0);
		glRotated([camera getRoll], 0.0, 0.0, -1.0);
		glScaled([camera getXScale], [camera getYScale], 1.0);
	}
	else
	{
		//[gLog add: warning withFormat: @"There is no camera!"];
	}

	MP_BEGIN_PROFILE(rend);
	[MPRenderable renderAll];
	MP_END_PROFILE(rend);
	[camera release];

	SDL_GL_SwapBuffers();

	// events
	NSArray *objects = nil;
	NSUInteger i = 0;
	int mx, my;
	double x = 0.0, y = 0.0;

	SDL_Event event;
	if( SDL_PollEvent(&event) )
	{
		if(event.type == SDL_QUIT)
		{
			[api postMessageWithName: @"exit"];
			done = YES;
		}
        if(event.type == SDL_KEYDOWN)
		{
			wchar_t c = event.key.keysym.unicode;
			NSString *decoded = [NSString stringWithFormat: @"%C", c];
			NSString *keyName = [NSString stringWithUTF8String: SDL_GetKeyName(event.key.keysym.sym)];
			[api postMessageWithName: @"keyDown" userInfo: [MPDictionary dictionaryWithObjectsAndKeys: 
				decoded, @"char", keyName, @"keyName", [NSString stringWithFormat: @"%d", event.key.keysym.sym], @"keyCode", nil]];
		}
#define MOUSE_EVENT(_type)\
			convertMouseCoordinates(event.button.x, event.button.y, winWidth, winHeight, &x, &y);\
			NSString *buttonId = [[NSString alloc] initWithFormat: @"%d", event.button.button];\
			NSString *xC = [[NSString alloc] initWithFormat: @"%f", x];\
			NSString *yC = [[NSString alloc] initWithFormat: @"%f", y];\
			\
			[api postMessageWithName: @"mouseButton" userInfo: \
				[MPDictionary dictionaryWithObjectsAndKeys: @#_type, @"state", \
							 buttonId, @"button", xC, @"X", yC, @"Y", nil]];\
			\
			[buttonId release];\
			[xC release];\
			[yC release];

		if(event.type == SDL_MOUSEBUTTONDOWN)
		{
			MOUSE_EVENT(down);
		}
		if(event.type == SDL_MOUSEBUTTONUP)
		{
			MOUSE_EVENT(up);
		}
	}

	// process mouse
	SDL_PumpEvents();
	SDL_GetMouseState(&mx, &my);
	convertMouseCoordinates(mx, my, winWidth, winHeight, &x, &y);
	objects = [[api getObjectSystem] getObjectsByFeature: @"mouse"];
	for(; i < [objects count]; ++i)
	{
		[[objects objectAtIndex: i] setXY: x : y];
	}

	MP_END_PROFILE(graphics_frame);
}

MP_HANDLER_OF_MESSAGE(showCursor)
{
	showCursor([[MP_MESSAGE_DATA objectForKey: @"state"] boolValue]);
}

MP_HANDLER_OF_MESSAGE(grabInput)
{
	grabInput([[MP_MESSAGE_DATA objectForKey: @"state"] boolValue]);
}
@end

