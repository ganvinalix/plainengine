#import <irrlicht.h>
#import <MPCore.h>

class MPIrrEventHandler : public irr::IEventReceiver
{
	id<MPAPI> api;
	MPProfilingStatistics keyStats;

private:
	//void convertMouseCoordinates(int x, int
public:

#define MOUSE_EVENT(eventCode, bti, up_down) \
	if (event.MouseInput.Event == irr:: eventCode) { \
		/*convert?*/ \
		float x = event.MouseInput.X; \
		float y = event.MouseInput.Y; \
		NSString *buttonId = [[NSString alloc] initWithFormat: @"%d", bti]; \
		NSString *xC = [[NSString alloc] initWithFormat: @"%f", x]; \
		NSString *yC = [[NSString alloc] initWithFormat: @"%f", y]; \
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

		// Remember whether each key is down or up
		if (event.EventType == irr::EET_KEY_INPUT_EVENT)
		{
			MPBeginProfilingSession(&keyStats);

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

			MPEndProfilingSession(&keyStats);
		}
		else if (event.EventType == irr::EET_MOUSE_INPUT_EVENT)
		{
			MOUSE_EVENT(EMIE_LMOUSE_PRESSED_DOWN, 1, down);
			MOUSE_EVENT(EMIE_MMOUSE_PRESSED_DOWN, 2, down);
			MOUSE_EVENT(EMIE_RMOUSE_PRESSED_DOWN, 3, down);
			MOUSE_EVENT(EMIE_LMOUSE_LEFT_UP, 1, up);
			MOUSE_EVENT(EMIE_MMOUSE_LEFT_UP, 2, up);
			MOUSE_EVENT(EMIE_RMOUSE_LEFT_UP, 3, up);
		}

		return false;
	}

#undef MOUSE_EVENT

	MPIrrEventHandler(id<MPAPI> theApi)
	{
		api = [theApi retain];
		MPInitProfiling(&keyStats);
	}
	~MPIrrEventHandler()
	{
		[[api log] add: notice withFormat: @"Key section statistics:\n %@\n", MPPrintProfilingStatistics(&keyStats)];
		[api release];
	}
};

