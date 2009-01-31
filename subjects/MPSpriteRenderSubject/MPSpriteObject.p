#include <Foundation/Foundation.h>
#include <MPAnimator.p>

@protocol MPSpriteObject <NSObject>
- (BOOL) isVisible;
- (void) setVisible: (BOOL)vis;

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

/*if node == nil then sprite will be attached to root*/
- (void) attachTo: (id<MPSpriteObject>)node;

- (void) setAnimator: (id<MPAnimator>)anAnim;
- (void) applyAnimation;
@end
