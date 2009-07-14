#import <Foundation/Foundation.h>
#import <MPIrrSceneNode.p>
#import <MPCore.h>
#import <irrlicht.h>

@interface MPGraphical : NSObject <MPIrrSceneNode>
{
	//irr::scene::ISceneNode *node;
	id nodeStrategy;
	irr::scene::ISceneManager *sceneManager;
}


- init;
- initWithObject: (id)anObject withSceneManager: (irr::scene::ISceneManager *)smgr;
- (void) dealloc;

+ newDelegateWithObject: (id)anObject withUserInfo: (void*)userInfo;

- (void) setFeature: (NSString *)name toValue: (id<MPVariant>)dt userInfo: (NSDictionary *)info;
@end

