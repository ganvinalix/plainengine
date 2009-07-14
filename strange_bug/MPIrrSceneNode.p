#include <Foundation/Foundation.h>

@protocol MPIrrSceneNode <NSObject>
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

/** if objh == 0  then sprite willn't be attached or will be deattached 
 		objh - handle of object in object system; if pointed object doesn't have feature then nothing happens */
- (void) attachTo: (MPHandle)objh;

- (NSUInteger) getInternalID;
@end

