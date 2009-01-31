#import <Foundation/Foundation.h>
#import <MPSpriteObject.p>
#import <MPAnimator.p>

@protocol MPRenderable
- initWithNode: (id<MPSpriteObject>)aNode;

- (void) bindToNode: (id<MPSpriteObject>) aNode;
- (id<MPSpriteObject>) getNode;

- (void) render;

- (BOOL) isVisible;
- (void) setVisible: (BOOL)vis;

- (BOOL) setTexture: (NSString *)name;
- (unsigned) getTextureId;

- (NSComparisonResult) compare: (id<MPRenderable>)arg;

- (void) setTextureAnimator: (id<MPAnimator>)anAnim;
@end

