#import <MPCamera.h>

MPCamera *camera = nil;

@implementation MPCamera
- initWithObject: (id<MPObject>)object
{
	sx = sy = 1.0;
	x = y = roll = 0.0;
	_object = object;
	x = [object getX];
	y = [object getY];
	roll = [object getRoll];

	if(camera) return [camera retain];

	[super init];
	camera = self;
	return self;
}
- (void) dealloc
{
	//[camera release];
	//camera = nil;

	[super dealloc];
}
+ newDelegateWithObject: (id<MPObject>)object
{
	return [[MPCamera alloc] initWithObject: object];
}

- (double) getX
{
	return x;
}
- (double) getY
{
	return y;
}

- (double) getRoll
{
	return roll;
}

- (double) getXScale
{
	return sx;
}
- (double) getYScale
{
	return sy;
}

- (void) setXY: (double)aX : (double)aY
{
	x = aX;
	y = aY;
}
- (void) setRoll: (double)aR
{
	roll = aR;
}

- (void) setScaleXY: (double)aX : (double)aY
{
	sx = aX;
	sy = aY;
}

- (void) moveByXY: (double)aX : (double)aY
{
	[_object setXY: x+aX : y+aY];
}

+ (MPCamera *) getCamera
{
	return camera;
}
@end

