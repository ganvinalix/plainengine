#import <MPCore.h>
#import <MPAttractorChainSubject.h>
#import <MPACSAttractedDelegate.h>

double energyTakingCoefficient = 1.5;
int maxEnergyQuants = 5;

@implementation MPAttractorChainSubject

#define LOAD_DOUBLE(x)\
	if ([params objectForKey: @#x])\
	{\
		x = [[params objectForKey: @#x] doubleValue];\
	}\

#define LOAD_INT(x)\
	if ([params objectForKey: @#x])\
	{\
		x = [[params objectForKey: @#x] intValue];\
	}\

- initWithString: (NSString *)aParams
{
	[super init];
	NSDictionary *params = parseParamsString(aParams);
	LOAD_DOUBLE(energyTakingCoefficient);
	LOAD_DOUBLE(attractingImpulseCoefficient);
	LOAD_DOUBLE(attractingRadius);
	LOAD_INT(maxEnergyQuants);
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
	 [MPACSAttractedDelegate setAPI: api];
}

- (void) start
{
	[[api getObjectSystem] registerDelegate: [MPACSAttractedDelegate class]];
}

- (void) stop
{
	[[api getObjectSystem] removeDelegate: [MPACSAttractedDelegate class]];
}

- (void) update
{

}

MP_HANDLER_OF_MESSAGE(attractorChainTick)
{
	const double quant = 1;
	const double takek = quant*energyTakingCoefficient;
	const double maxenergy = maxEnergyQuants*quant;

	NSArray *at = [[api getObjectSystem] getObjectsByFeature: @"chainedAttractor"];
	NSUInteger i, count = [at count];
	for (i=0; i<count; ++i)
	{
		id<MPObject> ca = [at objectAtIndex: i];
		NSArray *attractors = [[[ca getFeatureData: @"attracted"] stringValue] componentsSeparatedByString: @" "];
		NSUInteger acount = [attractors count];
		if ([[attractors objectAtIndex: 0] isEqualToString: @""])
		{
			acount = 0;
		}
		if (!acount)
		{
			[ca setFeature: @"chainedAttractor" toValue:
									[MPVariant variantWithDouble:
									[[ca getFeatureData: @"chainedAttractor"] doubleValue]-quant]];
		}
		else
		{
			double consumePerAttractor = quant/acount;
			NSUInteger j; 
			for (j=0; j<acount; ++j)
			{
				id<MPObject> attractor = [[api getObjectSystem] getObjectByName: [attractors objectAtIndex: j]];
				if ([attractor hasFeature: @"chainedAttractor"])
				{
					[attractor setFeature: @"chainedAttractor" toValue:
							 		[MPVariant variantWithDouble:
							 		[[attractor getFeatureData: @"chainedAttractor"] doubleValue]-consumePerAttractor*takek]];
				}
			}
			[ca setFeature: @"chainedAttractor" toValue:
									[MPVariant variantWithDouble:
									[[ca getFeatureData: @"chainedAttractor"] doubleValue]+quant]];
		}
	}
	for (i=0; i<count; ++i)
	{
		id<MPObject> ca = [at objectAtIndex: i];
		[ca lock];
		if ([[ca getFeatureData: @"chainedAttractor"] doubleValue] <= 0)
		{
			[ca removeFeature: @"chainedAttractor"];
			--i;
			--count;
		}
		else if ([[ca getFeatureData: @"chainedAttractor"] doubleValue] > maxenergy)
		{
			[ca setFeature: @"chainedAttractor" toValue: [MPVariant variantWithDouble: maxenergy]];
		}
		[ca unlock];
	}
}

@end


