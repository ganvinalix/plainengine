#import <Foundation/Foundation.h>
#import <MPNodeStrategy.p>
#import <MPCore.h>
#import <irrlicht.h>

/** Delegate class for "graphical" feature */
@interface MPGraphical : NSObject <MPIrrSceneNode>
{
	id<MPNodeStrategy> nodeStrategy;
	irr::scene::ISceneManager *sceneManager;
}

- init; // error
- initWithObject: (id)anObject withSceneManager: (irr::scene::ISceneManager *)smgr;
- (void) dealloc;

+ newDelegateWithObject: (id)anObject withUserInfo: (void*)userInfo;

- (void) setFeature: (NSString *)name toValue: (id<MPVariant>)dt userInfo: (NSDictionary *)info;
@end

