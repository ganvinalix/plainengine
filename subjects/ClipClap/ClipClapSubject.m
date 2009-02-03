#import <MPCore.h>
#import <ClipClapSubject.h>
#import <ClipClapHelpers.h>

// globals
id racquet = nil;
id cursor = nil;

@implementation ClipClapSubject

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
	[api release];

	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	api = [anAPI retain];
	objects = [api getObjectSystem];
}

- (void) start
{
	racquet = [objects newObjectWithName: @"racquet"];
	setupObject(api, racquet, @"racquet");
	cursor = [objects newObjectWithName: @"cursor"];
	[cursor setFeature: @"mouse"];
	//[cursor setFeature: @"renderable"];
	setupObject(api, cursor, @"racquet");
}

- (void) stop
{
	[cursor release];
	[racquet release];
}

- (void) update
{
	//[racquet setXY: [cursor getX], 0.0];
}


@end


