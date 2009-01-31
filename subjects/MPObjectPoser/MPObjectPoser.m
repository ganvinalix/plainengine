#import <MPCore.h>
#import <MPObjectPoser.h>

@protocol MPPositionedObject
-(double) getX;
-(double) getY;
-(double) getZ;
-(void) setXYZ: (double)aX : (double)aY : (double)aZ;
-(void) setRoll: (double)aRoll;
@end

@interface MPPositionedObject : NSObject <MPPositionedObject>
{
	double X, Y, Z;
}

-init;

@end

@implementation MPPositionedObject

-init
{
	X=Y=Z;
	return [super init];
}

-(double) getX
{
	return X;
}

-(double) getY
{
	return Y;
}
-(double) getZ
{
	return Z;
}

-(void) setXYZ: (double)aX : (double)aY : (double)aZ
{
	X=aX;
	Y=aY;
	Z=aZ;
}

-(void) setRoll: (double)aR
{
	
}
@end

@implementation MPObjectPoser

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	featuresArray = [[aParams componentsSeparatedByString: @" "] copy];
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
	[featuresArray release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{
	[[api getObjectSystem] registerDelegate: [MPPositionedObject class] forFeatures: featuresArray];
}

- (void) stop
{
	[[api getObjectSystem] removeDelegate: [MPPositionedObject class] forFeatures: featuresArray];
}

MP_HANDLER_OF_MESSAGE(consoleInput)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *str = [MP_MESSAGE_DATA objectForKey: @"commandparams"];
	
	if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"get"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id<MPPositionedObject> obj = (id)[[api getObjectSystem] getObjectByName: [arr objectAtIndex: 1]];
			#define MPOBJPOSER_GET(C, c)\
			if (([[arr objectAtIndex: 0] isEqualToString: @#C]) || ([[arr objectAtIndex: 0] isEqualToString: @#c]))\
			{\
				[[api log] add: info withFormat: @"%lf", [obj get##C]];\
			}

			MPOBJPOSER_GET(X, x);
			MPOBJPOSER_GET(Y, y);
			MPOBJPOSER_GET(Z, z);
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"setXYZ"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=4)
		{
			id<MPPositionedObject> obj = (id)[[api getObjectSystem] getObjectByName: [arr objectAtIndex: 3]];
			double X = [[arr objectAtIndex: 0] doubleValue];
			double Y = [[arr objectAtIndex: 1] doubleValue];
			double Z = [[arr objectAtIndex: 2] doubleValue];
			[obj setXYZ:X:Y:Z];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"setRoll"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id<MPPositionedObject> obj = (id)[[api getObjectSystem] getObjectByName: [arr objectAtIndex: 1]];
			double Roll = [[arr objectAtIndex: 0] doubleValue];
			Roll = Roll*3.1415f/180.0f;
			[obj setRoll:Roll];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"torque"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=4)
		{
			id obj = (id)[[api getObjectSystem] getObjectByName: [arr objectAtIndex: 3]];
			double x = [[arr objectAtIndex: 0] doubleValue];
			double y = [[arr objectAtIndex: 1] doubleValue];
			double z = [[arr objectAtIndex: 2] doubleValue];
			[obj applyTorqueWithXYZ:x:y:z];
		}
	}
	[pool release];
}

- (void) update
{

}

@end


