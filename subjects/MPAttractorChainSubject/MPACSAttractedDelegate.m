#import <MPACSAttractedDelegate.h>

id<MPAPI> gAPI=nil;

double attractingImpulseCoefficient = 30;
double attractingRadius = 0.15;

@implementation MPACSAttractedDelegate

+(void)setAPI: (id<MPAPI>)api
{
	gAPI = api;
}

+newDelegateWithObject: (id<MPObject>)object
{
	return [[self alloc] initDelegateWithObject: object];
}

-initDelegateWithObject: (id<MPObject>)object
{
	[super init];
	connectedObject = object;
	
	return self;
}

-(void)setFeature: (NSString *)name toValue: (id<MPVariant>)value
{
	if ([name isEqualToString: @"attracted"])
	{
		if (![connectedObject hasFeature: @"attractor"])
		{
			[connectedObject setFeature: @"chainedAttractor" toValue: [MPVariant variantWithString: @"2"]];
			[connectedObject setFeature: @"attractingRadius" toValue:
		   									[MPVariant variantWithDouble: attractingRadius]];
			[connectedObject setFeature: @"attractingImpulseCoefficient" toValue:
		   									[MPVariant variantWithDouble: attractingImpulseCoefficient]];
			[connectedObject setFeature: @"attractor"];
		}
	}
}

-(void)removeFeature: (NSString *)name
{
	if ([name isEqualToString: @"chainedAttractor"])
	{
		[connectedObject removeFeature: @"attractor"];
		[connectedObject removeFeature: @"attractingRadius"];
		[connectedObject removeFeature: @"attractingImpulseCoefficient"];
	}
}

@end

