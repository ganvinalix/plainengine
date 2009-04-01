#import <MPGraphical.h>

using namespace irr;

using namespace core;
using namespace scene;
using namespace video;
using namespace io;
using namespace gui;

@implementation MPGraphical
+ newDelegateWithObject: (id)anObject withUserInfo: (void*)userInfo
{
	return [[MPGraphical alloc] initWithObject: anObject withSceneManager: (ISceneManager *)userInfo];
}

- init
{
	MPAssert(0, @"MPGraphical: init call!");
	return nil;
}
- initWithObject: (id)anObject withSceneManager: (ISceneManager *)smgr;
- (void) dealloc;
@end
