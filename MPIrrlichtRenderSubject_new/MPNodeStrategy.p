#import <MPCore.h>
#import <MPIrrSceneNode.p>
#import <irrlicht.h>

@protocol MPNodeStrategy <MPIrr2DObject, NSObject>
// setAnimator?
// setFeature
- (void) setFeature: (NSString *)name toValue: (id<MPVariant>)dt userInfo: (NSDictionary *)info;

- (irr::scene::ISceneNode *) getSceneNode;

- init; // error
// (parent??? i think that attachment to the root node by default and attachTo method is enaugth) ID (and params ??? no, i think it could be grabbed from setFeature) for init
- initWithID: (NSUInteger)anID /*andParent: (irr::scene::ISceneNode *)aParent*/;
@end
