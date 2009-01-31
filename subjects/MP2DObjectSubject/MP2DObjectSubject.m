#import <MP2DObjectSubject.h>
#import <MP2DObjectDelegate.h>

@implementation MP2DObjectSubject

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
	[[api getObjectSystem] registerDelegate: [MP2DObjectDelegate class] forFeature: @"object2d"];
}

- (void) stop
{
	[[api getObjectSystem] removeDelegate: [MP2DObjectDelegate class] forFeature: @"object2d"];
}

- (void) update
{

}
@end

