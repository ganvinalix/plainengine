#import <MPCore.h>
#import <MPMemorySharingSubject.h>

@implementation MPMemorySharingSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	zoneDictionary = nil;
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
	zoneDictionary = [[NSMutableDictionary alloc] init];
}
- (void) stop
{
	[zoneDictionary release];
}

- (void) update
{
	
}

MP_HANDLER_OF_MESSAGE(widenSharedZone)
{
	NSString *name;
	name = [MP_MESSAGE_DATA objectForKey: @"name"];
	
	NSMutableData *zone;
	zone = [zoneDictionary objectForKey: name];

	if (zone)
	{
		NSUInteger size;
		size = stringToUnsigned([MP_MESSAGE_DATA objectForKey: @"size"]);
	
		if ([zone length]<size)
		{
			[zone setLength: size];
			id dict;
			dict = [[MPMutableDictionary alloc] init];
			[dict setObject: unsignedToString([zone length]) 		forKey: @"size"];
			[dict setObject: name 									forKey: @"name"];
			[api postMessageWithName: @"sharedZoneWidened" userInfo: dict];
			[dict release];
		}
	}

}

MP_HANDLER_OF_MESSAGE(createSharedZone)
{
	NSString *name;
	name = [MP_MESSAGE_DATA objectForKey: @"name"];
	
	NSMutableData *zone;
	zone = [zoneDictionary objectForKey: name];

	NSUInteger size;
	size = stringToUnsigned([MP_MESSAGE_DATA objectForKey: @"size"]);
	
	if (zone)
	{
		if ([zone length]<size)
		{
			[zone setLength: size];
			id dict;
			dict = [[MPMutableDictionary alloc] init];
			[dict setObject: unsignedToString([zone length]) 		forKey: @"size"];
			[dict setObject: name 									forKey: @"name"];
			[api postMessageWithName: @"sharedZoneWidened" userInfo: dict];
			[dict release];
		}
	}
	else
	{
		zone = [NSMutableData dataWithLength: size];
		[zoneDictionary setObject: zone forKey: name];
		
		id dict;
		dict = [[MPMutableDictionary alloc] init];
		[dict setObject: pointerToString([zone mutableBytes])	forKey: @"pointer"];
		[dict setObject: unsignedToString([zone length]) 		forKey: @"size"];
		[dict setObject: name 									forKey: @"name"];
		[api postMessageWithName: @"sharedZoneCreated" userInfo: dict];
		[dict release];
	}
}

@end


