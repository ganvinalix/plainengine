#import <MPCore.h>
#import <irrlicht.h>

@interface MPRenderableDelegate : NSObject
{
	irr::scene::ISceneNode *node;
}
- (double) getX;
- (double) getY;
- (double) getZ;

- (void) setXYZ: (double)x :(double)y :(double)z;
//- (void) setRotationByXYZ: (double)x :(double)y :(double)z;

- init;
- (void) dealloc;

+ (void) setSeceneManager: (irr::scene::ISceneManager *)aMgr;
@end

