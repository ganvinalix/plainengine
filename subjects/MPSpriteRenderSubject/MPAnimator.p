#import<Foundation/Foundation.h>

@protocol MPAnimator <NSObject>
- initWithTime: (NSUInteger)aTime;
- initWithTime: (NSUInteger)aTime userInfo: (NSDictionary *)params;

- (double) getX;
- (double) getY;

- (double) getXScale;
- (double) getYScale;

- (double) getRoll;

- (void) setTime: (NSUInteger)aTime XY: (double)aX : (double)aY scaleXY: (double)aSX : (double)aSY roll: (double)aRoll;
@end

