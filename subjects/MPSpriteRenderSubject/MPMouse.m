#import <MPMouse.h>

@implementation MPMouse
- initWithObject: (id)object
{
	sx = sy = 1.0;
	x = y = roll = 0.0;
	_object = object;
	x = [object getX];
	y = [object getY];

	[super init];
	return self;
}
- (void) dealloc
{
	[super dealloc];
}
+ newDelegateWithObject: (id)object
{
	return [[MPMouse alloc] initWithObject: object];
}

- (double) getX
{
	//printf("%f\n\n", x);
	return x;
}
- (double) getY
{
	return y;
}

- (void) setXY: (double)aX : (double)aY
{
	x = aX;
	y = aY;
}

- (void) moveByXY: (double)aX : (double)aY
{
	[_object setXY: x+aX : y+aY];
}

@end

