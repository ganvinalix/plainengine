#import <MPRenderable.p>
#import <MPSpriteObject.p>

@interface MPRenderable : NSObject<MPRenderable>
+ addRenderableForNode: (id<MPSpriteObject>)aNode;
+ (void) removeRenderable: (id<MPRenderable>)aDrawer; 

+ (void) renderAll;
@end

