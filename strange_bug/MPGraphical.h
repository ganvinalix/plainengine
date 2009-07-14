#import <Foundation/Foundation.h>
#import <MPIrrSceneNode.p>
#import <MPCore.h>
#import <irrlicht.h>

@interface MPGraphical : NSObject <MPIrrSceneNode>
{
	//irr::scene::ISceneNode *node;
	id nodeStrategy<MPIrrSceneNode>;
	irr::scene::ISceneManager *sceneManager;
}

+ newDelegateWithObject: (id)anObject withUserInfo: (void*)userInfo;

- init;
- (void) dealloc;
@end

