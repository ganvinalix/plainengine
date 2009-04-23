#import <MPCore.h>
#import <MPDataSaverSubject.h>

@implementation MPDataSaverSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	dataFileName = [aParams copy]; 
	dataTree = [NSMutableDictionary new];
	return self;
}

- (void) save
{
	[dataTree writeToFile: dataFileName atomically: YES];
	//[[api getObjectSystem] saveToFile: @"objects.dat"];
}

- init
{
	return [self initWithString: @"data.dat"];
}

- (void) dealloc
{
	if (api)
	{
		[api release];
	}
	[dataFileName release];
	[dataTree release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{
	[dataTree release];
	dataTree = [[NSMutableDictionary alloc] initWithContentsOfFile: dataFileName];
	if (!dataTree)
	{
		dataTree = [NSMutableDictionary new];
	}
	//[[api getObjectSystem] loadFromFile: @"objects.dat"];
}

- (void) stop
{
	[self save];
	[dataTree removeAllObjects];
}

- (void) update
{

}

MP_HANDLER_OF_MESSAGE(saveData)
{
	NSMutableDictionary *category;
	category = [dataTree objectForKey:
		[MP_MESSAGE_DATA objectForKey: @"category"]];
	if (!category)
	{
		category = [NSMutableDictionary new];
		[dataTree setObject: category forKey: 
				[MP_MESSAGE_DATA objectForKey: @"category"]];
		[category release];
	}
	[category setObject: [MP_MESSAGE_DATA objectForKey: @"data"]
				 forKey: [MP_MESSAGE_DATA objectForKey: @"key"]];
}

MP_HANDLER_OF_MESSAGE(save)
{
	[self save];
}

MP_HANDLER_OF_REQUEST(loadData)
{
	NSString *result;
	NSMutableDictionary *category;
	category = [dataTree objectForKey:
		[MP_MESSAGE_DATA objectForKey: @"category"]];
	result = [category objectForKey: [MP_MESSAGE_DATA objectForKey: @"key"]];
	if (!result)
	{
		result = @"";
	}
	MP_SET_RESULT([MPVariant variantWithString: result]);
}

@end


