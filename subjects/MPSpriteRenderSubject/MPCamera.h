#import <Foundation/Foundation.h>
#import <MPCore.h>

@interface MPCamera : NSObject
{
	double x, y, sx, sy, roll;
	id _object;
}
+ (MPCamera *) getCamera;

- initWithObject: (id<MPObject>)object;

- (double) getX;
- (double) getY;

- (double) getRoll;

- (double) getXScale;
- (double) getYScale;

- (void) setXY: (double)aX : (double)aY;
- (void) setRoll: (double)aR;

- (void) setScaleXY: (double)aX : (double)aY;

- (void) moveByXY: (double)aX : (double)aY;
@end

