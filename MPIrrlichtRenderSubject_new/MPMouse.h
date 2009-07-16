#import <Foundation/Foundation.h>
#import <MPCore.h>

@interface MPMouse : NSObject
{
	double x, y, sx, sy, roll;
	id _object;
}
- initWithObject: (id)object;

- (double) getX;
- (double) getY;

- (void) setXY: (double)aX : (double)aY;
- (void) moveByXY: (double)aX : (double)aY;
@end

