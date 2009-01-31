#import <MPCore.h>
#import <MPConsoleBatchSubject.h>

@implementation MPConsoleBatchSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	initializer = [aParams copy];
	initializeBatch = YES;
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
	[initializer release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{
	initializeBatch = YES;
}

- (void) stop
{

}

-(void) executeBatch: (NSString *)runstring
{
	NSArray *params = [runstring componentsSeparatedByString: @" "];
	NSUInteger parind, parcount = [params count];
	if (![params count])
	{
		return;
	}
	NSString *batch = [NSString stringWithContentsOfFile: [params objectAtIndex: 0]];
	NSArray *commands = [batch componentsSeparatedByString: MP_EOL];
	NSEnumerator *enumer = [commands objectEnumerator];
	NSString *cur = nil;
	while ((cur = [enumer nextObject]) != nil)
	{
		NSMutableString *current = [NSMutableString stringWithString: cur];
		for (parind=0; parind<parcount; ++parind)
		{
			stringReplace(current, [NSString stringWithFormat: @"$%u", parind], [params objectAtIndex: parind]);
		}
		NSUInteger count = [current length];
		if (!count)
		{
			continue;
		}
		if ([current characterAtIndex: 0] == '#')
		{
			continue;
		}
		NSMutableString *commandname, *commandparams;
		commandname = [NSMutableString string];
		commandparams = [NSMutableString string];
		NSMutableString *cur = commandname;
		NSUInteger i;
		for (i=0; i<count; ++i)
		{
			if (([current characterAtIndex: i] == ' ') && (cur != commandparams))
			{
				cur = commandparams;
				continue;
			}
			[cur appendFormat: @"%C", [current characterAtIndex: i]];
		}
		if ([commandname isEqualToString: @"e"])
		{
			[self executeBatch: commandparams];
		}
		else if ([commandname isEqualToString: @"sleep"])
		{
			MP_SLEEP([commandparams intValue]);
		}
		else
		{
			id dict = [MPMutableDictionary dictionary];
			[dict setObject: current forKey: @"message"];
			[dict setObject: commandname forKey: @"commandname"];
			[dict setObject: commandparams forKey: @"commandparams"];
			[api postMessageWithName: @"consoleInput" userInfo: dict];
		}
	}
}

MP_HANDLER_OF_MESSAGE(consoleInput)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *str = [MP_MESSAGE_DATA objectForKey: @"commandparams"];
	
	if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"e"])
	{
		[self executeBatch: str];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"helpbatch"])
	{
		[[api log] add: info withFormat: @"\ne <filename> - executes commands in file one-by-one"
										  "\n"
										  "\nIn batch special commands may be used:"
										  "\nsleep <n> \t- sleep for n ms"
										  "\n#commentline \t- this line would be ignored"];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"help"])
	{
		[[api log] add: info withFormat: @"helpbatch - MPConsoleBatchSubject help"];
	}

	[pool release];
}

- (void) update
{
	if (initializeBatch && ![initializer isEqualToString: @""])
	{
		initializeBatch = NO;
		[self executeBatch: initializer];
	}
}

@end


