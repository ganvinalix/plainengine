#import <MP2DObjectDelegate.h>

#define SAFE_RETURN(arg) \
	double res = 0.0; \
	[_lock lock]; \
	res = arg; \
	[_lock unlock]; \
	return res;

@implementation MP2DObjectDelegate
- initWithObject: (id<MPObject>)object
{
	[super init];

	x = y = sx = sy = roll = 0.0;
	z_order = 0;

	_object = [object retain];
	_lock = [NSLock new];

	return self;
}
- init
{
	return [self initWithObject: nil];
}
+ newDelegateWithObject: (id<MPObject>)object
{
	return [[MP2DObjectDelegate alloc] initWithObject: object];
}
- (void) dealloc
{
	[_object release];
	[_lock release];
	[super dealloc];
}

- (double) getX
{
	SAFE_RETURN(x);
}
- (double) getY
{
	SAFE_RETURN(y);
}
- (unsigned) getZOrder
{
	SAFE_RETURN(z_order);
}

- (double) getRoll
{
	SAFE_RETURN(roll);
}

- (double) getXScale
{
	SAFE_RETURN(sx);
}
- (double) getYScale
{
	SAFE_RETURN(sy);
}

- (void) setXY: (double)aX : (double)aY
{
	[_lock lock];
	x = aX;
	y = aY;
	[_lock unlock];
}
- (void) setZOrder: (unsigned)aZo
{
	[_lock lock];
	z_order = aZo;
	[_lock unlock];
}
- (void) setRoll: (double)aR
{
	[_lock lock];
	roll = aR;
	[_lock unlock];
}

- (void) setScaleXY: (double)aX : (double)aY
{
	[_lock lock];
	sx = aX;
	sy = aY;
	[_lock unlock];
}

- (void) moveByXY: (double)aX : (double)aY
{
	[_object setXY: x+aX : y+aY];
}
@end

