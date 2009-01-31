#include <Foundation/Foundation.h>

@protocol MP2DObject <NSObject>

- (double) getX;
- (double) getY;
- (unsigned) getZOrder;

- (double) getRoll;

- (double) getXScale;
- (double) getYScale;

- (void) setXY: (double)aX : (double)aY;
- (void) setZOrder: (unsigned)aZo;
- (void) setRoll: (double)aR;

- (void) setScaleXY: (double)aX : (double)aY;

- (void) moveByXY: (double)aX : (double)aY;

@end
