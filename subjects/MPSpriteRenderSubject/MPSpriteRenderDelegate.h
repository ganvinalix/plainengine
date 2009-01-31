#import <MPSpriteObject.p>
#import <MPCore.h>

@interface MPSpriteRenderDelegate : NSObject <MPSpriteObject>
{
	double x, y, sx, sy, roll;
	double ex, ey, esx, esy, eroll;
	unsigned z_order;

	NSLock *_lock;
	id<MPObject, MPSpriteObject> _object;

	id parent;
	NSMutableArray *children;
	id drawer;
	BOOL visible;
	id<MPAnimator> animator;
}
+ newDelegateWithObject: (id<MPObject>)object;

- (void) attachChild: (MPSpriteRenderDelegate *)aChild;
- (void) deattachChild: (MPSpriteRenderDelegate *)aChild;
- (void) setFeature: (NSString *)name toValue: (id<MPVariant>)dt userInfo: (NSDictionary *)info;
@end

MPSpriteRenderDelegate * GetRootNode();

