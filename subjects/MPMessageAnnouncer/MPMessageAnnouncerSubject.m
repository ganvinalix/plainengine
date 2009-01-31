#import <MPCore.h>
#import <MPMessageAnnouncerSubject.h>

@implementation MPMessageAnnouncerSubject

- initWithString: (NSString *)aParams
{
	NSArray *params;
	params = [aParams componentsSeparatedByString: @" "];
	banned = [[NSMutableArray alloc] init];
	NSUInteger i, count = [params count];
	for (i=0; i<count; ++i)
	{
		if ([[params objectAtIndex: i] length] >= 2)
		{
			if ([[params objectAtIndex: i] characterAtIndex: 0] == '-')
			{
				NSString *str = [[params objectAtIndex: i] substringFromIndex: 1];
				[banned addObject: str];
			}
		}
	}
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

- (void) update
{

}

MP_HANDLER_OF_ANY_MESSAGE
{
	if (![banned containsObject: MP_MESSAGE_NAME])
	{
		[[api log] add: info withFormat: @"MPMessageAnnouncerSubject: Message \"%@\" sent with params\n\t%@;",
			MP_MESSAGE_NAME,
			MP_MESSAGE_DATA];
	}
}

@end


