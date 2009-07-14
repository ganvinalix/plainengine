#import <irrlicht.h>
#import <MPCore.h>

class MPIrrEventHandler : public irr::IEventReceiver
{
	id<MPAPI> api;
	MPProfilingStatistics keyStats;
public:
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
			//MOUSE_EVENT(
		}

		return false;
	}

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

