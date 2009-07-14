#import <MPRenderableDelegate.h>

using namespace irr;

using namespace core;
using namespace scene;

@implementation MPRenderableDelegate

ISceneManager *manager = NULL;

- (double) getX
{
	return node->getPosition().X / 10.0;
}
- (double) getY
{
	return node->getPosition().Y / 10.0;
}
- (double) getZ
{
	return node->getPosition().Z / 10.0;
}

- (void) setXYZ: (double)x :(double)y :(double)z
{
	node->setPosition(core::vector3df(x*10.0f, y*10.0f, z*10.0f));
}

- init
{
	if(!manager) return nil;

	[super init];
	node = manager->addCubeSceneNode();
	node->setPosition(core::vector3df(0,0,0));
	node->setMaterialFlag(video::EMF_LIGHTING, true);
	manager->addTextSceneNode(manager->getGUIEnvironment()->getBuiltInFont(), L"PS & VS & EMT_SOLID", video::SColor(255,0,0,255), node);


	return self;
}
- (void) dealloc
{
	manager->addToDeletionQueue(node);
	node->drop();

	[super dealloc];
}

+ (void) setSeceneManager: (ISceneManager *)aMgr
{
	manager = aMgr;
}
@end

