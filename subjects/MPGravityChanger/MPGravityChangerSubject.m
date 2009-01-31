#import <MPCore.h>
#import <MPGravityChangerSubject.h>

@implementation MPGravityChangerSubject

- initWithString: (NSString *)aParams
{
	[super init];
	k=[aParams doubleValue];
	if (k<=0)
	{
		k=1.f;
	}
	X=Y=0;
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

MP_HANDLER_OF_MESSAGE(mouseButton)
{
	if ([[MP_MESSAGE_DATA objectForKey: @"button"] isEqualToString: @"3"])
	{
		NSString *state = [MP_MESSAGE_DATA objectForKey: @"state"];
		if ([state isEqualToString: @"down"])
		{
			X = [[MP_MESSAGE_DATA objectForKey: @"X"] doubleValue];
			Y = [[MP_MESSAGE_DATA objectForKey: @"Y"] doubleValue];
		}
		else if ([state isEqualToString: @"up"])
		{
			X = [[MP_MESSAGE_DATA objectForKey: @"X"] doubleValue] - X;
			Y = [[MP_MESSAGE_DATA objectForKey: @"Y"] doubleValue] - Y;
			X*=k;
			Y*=k;
			id dict = [MPMutableDictionary new];
			[dict setObject: [NSString stringWithFormat: @"%f", X] forKey: @"X"];
			[dict setObject: [NSString stringWithFormat: @"%f", Y] forKey: @"Y"];
			[api postMessageWithName: @"setGravity" userInfo: dict];
			[dict release];
		}
	}
}

@end


