#import <MPCore.h>
#import <MPConsoleInputMessagerSubject.h>

@implementation MPConsoleInputMessagerSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
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

}

- (void) stop
{

}

void parseParams(NSString *str, NSMutableString *name, id dict)
{
	NSArray *arr = [str componentsSeparatedByString: @"/"];
	[name setString: [arr objectAtIndex: 0]];

	//params parsing
	int i, count = [arr count];
	for (i=1; i<count; ++i)
	{
		NSArray *msg;
		msg = [[arr objectAtIndex: i] componentsSeparatedByString: @"="];
		NSString *paramname;
		NSMutableString *paramvalue;	
		paramname = [msg objectAtIndex: 0];
		//stick together paramvalue parts ("paramname=a=b" -> paramvalue="a=b")
		int msc = [msg count];
		if (msc>1)
		{
			paramvalue = [NSMutableString string];
			int j;
			for (j=1; j<msc; ++j)
			{
				//must not put '=' on first paramvalue part
				if (j!=1)
				{
					[paramvalue appendFormat: @"=%@", [msg objectAtIndex: j]];
				}
				else
				{
					[paramvalue appendFormat: @"%@", [msg objectAtIndex: j]];
				}
			}
		}
		else
		{
			paramvalue = [NSMutableString string];
		}
		[dict setObject: paramvalue forKey: paramname];
	}

}

MP_HANDLER_OF_MESSAGE(consoleInput)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *str = [MP_MESSAGE_DATA objectForKey: @"commandparams"];
	
	if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"m"])
	{
		id dict = [MPMutableDictionary new];
		NSMutableString *nam = [NSMutableString string];
		parseParams(str, nam, dict);
		[api postMessageWithName: nam userInfo: dict];
		[dict release];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"r"])
	{
		id dict = [MPMutableDictionary new];
		NSMutableString *nam = [NSMutableString string];
		parseParams(str, nam, dict);
		id<MPVariant> result = [api postRequestWithName: nam userInfo: dict];
		[dict release];
		[[api log] add: info withFormat: @"Result of request \"%@\" is: \"%@\"", nam, result];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"q"])
	{
		[api postMessageWithName: @"exit"];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"helpmsg"])
	{
		[[api log] add: info withFormat: @"\nm <name>{/param[=paramvalue]}\t - posts notification 'name' with params\n"
											"r <name>{/param[=paramvalue]}\t - posts request 'name' with params. Result will be logged"];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"help"])
	{
		[[api log] add: info withFormat: @"helpmsg - MPConsoleInputMessagerSubject help"];
	}

	[pool release];
}

- (void) update
{

}

@end


