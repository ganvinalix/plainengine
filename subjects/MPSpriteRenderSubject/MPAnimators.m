#import <MPAnimator.p>

#define FOR_PARAM(name) \
		NSString *name = [info objectForKey: @#name]; \
		if(name)\
			if(![name isEqual: @""])

@interface ConstantMovement : NSObject<MPAnimator>
{
	NSUInteger startTime;
	double x, y, sx, sy, roll, _fps;
}
@end

@implementation ConstantMovement
- initWithTime: (NSUInteger)aTime userInfo: (NSDictionary *)info;
{
	[super init];

	_fps = 1.0;
	if(info)
	{
		FOR_PARAM(fps)
		{
			_fps = [fps doubleValue];
		}
	}
	startTime = aTime;
	x = y = roll = 0;
	sx = sy = 0.1;

	return self;
}
- initWithTime: (NSUInteger)aTime
{
	return [self initWithTime: aTime userInfo: nil];
}

- (double) getX
{
	return x;
}
- (double) getY
{
	return y;
}

- (double) getXScale
{
	return sx;
}
- (double) getYScale
{
	return sy;
}

- (double) getRoll
{
	return roll;
}

- (void) setTime: (NSUInteger)aTime XY: (double)aX : (double)aY scaleXY: (double)aSX : (double)aSY roll: (double)aRoll
{
	NSUInteger time = aTime - startTime;
	time *= _fps;
	x = aX;
	x += time*0.0001;
	y = aY;
	sx = aSX;
	sy = aSY;
	roll = aRoll;
	//roll += time*0.01;
}
@end

@interface FramedTexture : NSObject<MPAnimator>
{
	NSUInteger startTime;
	double x, y, sx, sy, roll, _fps;
	int _framesCount, _cycles;
	double currentCycle;
}
@end

@implementation FramedTexture
- initWithTime: (NSUInteger)aTime userInfo: (NSDictionary *)info;
{
	[super init];

	_fps = 1.0;
	_framesCount = 4;
	_cycles = 0;
	currentCycle = 0.0;
	if(info)
	{
		FOR_PARAM(fps)
		{
			_fps = [fps doubleValue];
		}
		FOR_PARAM(framesCount)
		{
			_framesCount = [framesCount intValue];
		}
		FOR_PARAM(cycles)
		{
			_cycles = [cycles intValue];
		}
	}
	startTime = aTime;
	x = y = roll = 0;
	sx = sy = 0.1;

	return self;
}
- initWithTime: (NSUInteger)aTime
{
	return [self initWithTime: aTime userInfo: nil];
}

- (double) getX
{
	return x;
}
- (double) getY
{
	return y;
}

- (double) getXScale
{
	return sx;
}
- (double) getYScale
{
	return sy;
}

- (double) getRoll
{
	return roll;
}

- (void) setTime: (NSUInteger)aTime XY: (double)aX : (double)aY scaleXY: (double)aSX : (double)aSY roll: (double)aRoll
{
	if(_cycles == -1) return;

	NSUInteger time = aTime - startTime;
	time /= 1000/_fps;

	currentCycle = time/_framesCount;
	if( (_cycles != 0) && (currentCycle == _cycles) )
	{
		_cycles = -1;
		return;
	}
	//printf("%f %d\n", currentCycle, _cycles);
	
	x = aX;
	y = aY;
	y -= aSY*time/_framesCount;
	sx = aSX;
	sy = aSY/_framesCount;
	roll = aRoll;

}
@end
