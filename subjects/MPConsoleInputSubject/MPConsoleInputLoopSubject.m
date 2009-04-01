#import <MPCore.h>
#import <MPConsoleInputLoopSubject.h>

@implementation MPConsoleInputLoopSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	dictionaryPool = [[MPPool alloc] initWithClass: [MPMutableDictionary class]];
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
	[dictionaryPool release];
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

MP_HANDLER_OF_MESSAGE(consoleInput)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *str = [MP_MESSAGE_DATA objectForKey: @"commandparams"];
	
	if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"repeat"])
	{
		NSMutableString *head, *body;
		head = [NSMutableString string];
		body = [NSMutableString string];
		separateString(str, head, body, @":");
		stringTrimRight(head);
		stringTrimLeft(body);
		NSArray *headparams;
		headparams = [head componentsSeparatedByString: @" "];
		NSUInteger headparamscount = [headparams count];
		if ( (![body isEqualToString: @""]) && (headparamscount) )
		{
			NSInteger i, start=1, finish, step=1;
			NSString *varName;
			varName = [NSString stringWithFormat: @"$%@", [headparams objectAtIndex: 0]];
			if (headparamscount == 2)
			{
				finish = [[headparams objectAtIndex: 1] intValue];
			}
			else if (headparamscount == 3)
			{
				start = [[headparams objectAtIndex: 1] intValue];
				finish = [[headparams objectAtIndex: 2] intValue];
			}
			else
			{
				start = [[headparams objectAtIndex: 1] intValue];
				finish = [[headparams objectAtIndex: 2] intValue];
				step = [[headparams objectAtIndex: 3] intValue];
			}
			NSMutableString *commandname, *commandparams;
		    commandname = [NSMutableString string];	
		    commandparams = [NSMutableString string];	
			for (i=start; i<=finish; i+=step)
			{
				NSMutableString *command = [NSMutableString stringWithString: body];
				stringReplace(command, varName, [NSString stringWithFormat: @"%ld", i]);
				separateString(command, commandname, commandparams, @" ");
				id dict = [dictionaryPool newObject];
				[dict setObject: command		forKey: @"message"];
				[dict setObject: commandname	forKey: @"commandname"];
				[dict setObject: commandparams	forKey: @"commandparams"];
				[api postMessageWithName: @"consoleInput" userInfo: dict];
				[dict release];
			}
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"seq"])
	{
		NSArray *sequence = [str componentsSeparatedByString: @","];

		NSMutableString *commandname, *commandparams;
	    commandname = [NSMutableString string];	
	    commandparams = [NSMutableString string];	
		
		NSUInteger i, count = [sequence count];
		for (i=0; i<count; ++i)
		{
			NSMutableString *command=[NSMutableString stringWithString: [sequence objectAtIndex: i]];
			stringTrimLeft(command);
			separateString(command, commandname, commandparams, @" ");
			id dict = [dictionaryPool newObject];
			[dict setObject: commandname	forKey: @"commandname"];
			[dict setObject: commandparams	forKey: @"commandparams"];
			[api postMessageWithName: @"consoleInput" userInfo: dict];
			[dict release];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"helploop"])
	{
		[[api log] add: info withFormat: @"\nrepeat <v> <c>:<command> - repeats <command> n times,"
		   								  "\n    replacing all occurances of '$<v>' to current counter value"
										  "\nrepeat <v> <s> <f>:<command> - repeats <command>, incrementing"
										  "\n    counter from <s> to <f>"
		   								  "\n    replacing all occurances of '$<v>' to current counter value"
										  "\nrepeat <v> <s> <f> <k>:<command> - repeats <command>, incrementing"
										  "\n    counter from <s> to <f> by <k>"
		   								  "\n    replacing all occurances of '$<v>' to current counter value"
										  "\nseq <command1>{, <command2>} - executes comma-separated list of commands"
										  "\n"];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"help"])
	{
		[[api log] add: info withFormat: @"helploop - MPConsoleLoopSubject help"];
	}

	[pool release];
}

- (void) update
{

}

@end


