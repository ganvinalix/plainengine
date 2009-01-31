#import <Foundation/Foundation.h>
#import <MPRenderable.h>

@interface MPSprite : MPRenderable 
{
	id<MPSpriteObject> node;
	BOOL visible;
	unsigned texture;
	NSString *texName;
	id<MPAnimator> texAnimator;
}
@end

