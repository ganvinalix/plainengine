#import <MPCore.h>
#import <MPConsoleInputSubject.h>

@implementation MPConsoleInputSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	dictpool = [[MPPool alloc] initWithClass: [MPMutableDictionary class]];
	strpool = [[MPPool alloc] initWithClass: [NSMutableString class]];
	buf[MPCIS_BUFLEN] = '\0';
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
	[strpool release];
	[dictpool release];
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

- (void) update
{

	int i;
	//printf(">");
	for (i=0; i<MPCIS_BUFLEN; ++i)
	{
		char c = getc(stdin); //O_O
		if (c != '\n')
		{
			buf[i]=c;
		}
		else
		{
			buf[i] = '\0';
			break;
		}
	}

	//scanf("%255s", buf);

	id dict = [dictpool newObject];
	NSMutableString *str = [strpool newObject];
	NSMutableString *cmdname = [strpool newObject];
	NSMutableString *cmdparams = [strpool newObject];
	[str setString: @""];
	[str appendFormat: @"%s", buf];
	[cmdname setString: @""];
	[cmdparams setString: @""];

	NSMutableString *current = cmdname;
	NSUInteger count = [str length];
	for (i=0; i<count; ++i)
	{
		if (([str characterAtIndex: i] == ' ') && (current != cmdparams))
		{
			current = cmdparams;
			continue;
		}
		[current appendFormat: @"%C", [str characterAtIndex: i]];
	}

	//[dict setObject: str forKey: @"message"];
	[dict setObject: cmdname forKey: @"commandname"];
	[dict setObject: cmdparams forKey: @"commandparams"];
	[api postMessageWithName: @"consoleInput" userInfo: dict];
	[str release];
	[cmdname release];
	[cmdparams release];
	[dict release];
}

@end


