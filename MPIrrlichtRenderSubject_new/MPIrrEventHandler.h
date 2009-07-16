#import <irrlicht.h>
#import <MPCore.h>
#import <MPIrrSceneNode.p>

class MPIrrEventHandler : public irr::IEventReceiver
{
	id<MPAPI> api;
	irr::IrrlichtDevice *device;
   	irr::scene::ISceneManager *smgr;

	double X, Y;

private:
	void updateMouseCoordinates()
	{
		irr::gui::ICursorControl *cc = device->getCursorControl();
		X = cc->getRelativePosition().X;
		Y = cc->getRelativePosition().Y;
		X = 2.0*(X - 0.5); Y = -2.0*(Y - 0.5);

		// TODO correction with camera pos/scale
	}

public:

#define MOUSE_EVENT(eventCode, bti, up_down) \
	if (event.MouseInput.Event == irr:: eventCode) { \
		updateMouseCoordinates(); \
		NSString *buttonId = [[NSString alloc] initWithFormat: @"%d", bti]; \
		NSString *xC = [[NSString alloc] initWithFormat: @"%f", X]; \
		NSString *yC = [[NSString alloc] initWithFormat: @"%f", Y]; \
		\
		NSDictionary *msgDict = [[NSDictionary alloc] initWithObjectsAndKeys: @#up_down, @"state", \
			buttonId, @"button", xC, @"X", yC, @"Y", nil]; \
		[api postMessageWithName: @"mouseButton" userInfo: msgDict]; \
		\
		[msgDict release]; \
		[yC release]; [xC release]; \
		[buttonId release]; \
	}

	virtual bool OnEvent(const irr::SEvent& event)
	{
		NSString *const UpDown[] = {@"keyUp", @"keyDown"};
		NSArray *objects = nil;

		if (event.EventType == irr::EET_KEY_INPUT_EVENT)
		{
			// prepare
			wchar_t c = event.KeyInput.Char;
			NSString *decoded = [[NSString alloc] initWithFormat: @"%C", c]; 
			NSString *keyName = @""; //[NSString stringWithUTF8String: SDL_GetKeyName(event.key.keysym.sym)];
			NSString *keyCode = [[NSString alloc] initWithFormat: @"%d", event.KeyInput.Key];
			NSDictionary *msgDict = [[MPDictionary alloc] 
				initWithObjectsAndKeys: decoded, @"char", keyName, @"keyName", keyCode, @"keyCode", nil];
			// send message
			[api postMessageWithName: UpDown[event.KeyInput.PressedDown] userInfo: msgDict];
			// cleanup
			[msgDict release];
			[decoded release];
			//[keyName release];
			[keyCode release];
		}
		else if (event.EventType == irr::EET_MOUSE_INPUT_EVENT)
		{
			MOUSE_EVENT(EMIE_LMOUSE_PRESSED_DOWN, 1, down);
			MOUSE_EVENT(EMIE_MMOUSE_PRESSED_DOWN, 2, down);
			MOUSE_EVENT(EMIE_RMOUSE_PRESSED_DOWN, 3, down);
			MOUSE_EVENT(EMIE_LMOUSE_LEFT_UP, 1, up);
			MOUSE_EVENT(EMIE_MMOUSE_LEFT_UP, 2, up);
			MOUSE_EVENT(EMIE_RMOUSE_LEFT_UP, 3, up);

			if (event.MouseInput.Event == irr::EMIE_MOUSE_MOVED) 
			{
				updateMouseCoordinates();
				objects = [[api getObjectSystem] getObjectsByFeature: @"mouse"];
				NSUInteger i = 0;
				for(; i < [objects count]; ++i)
				{
					// if object appears in this array then itresponds to setXY selector 
					// because of delegate binded to the "mouse" feature
					[[objects objectAtIndex: i] setXY: X : Y];
				}
			}
		}

		return false;
	}

#undef MOUSE_EVENT

	MPIrrEventHandler(id<MPAPI> theApi, irr::IrrlichtDevice *theDevice): device(theDevice), X(0.0), Y(0.0)
	{
		NSCAssert(device != NULL, @"MPIrrEventHandler: device is NULL!");
		smgr = device->getSceneManager();

		api = [theApi retain];
	}
	~MPIrrEventHandler()
	{
		[api release];
	}
};

