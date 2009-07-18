#import <MPGraphical.h>

using namespace irr;

using namespace core;
using namespace scene;
using namespace video;
using namespace io;
using namespace gui;

@implementation MPGraphical

NSLock *sceneManagerLock = nil;

+ (void) load
{
	// TODO Spin?
	sceneManagerLock = [NSRecursiveLock new];
}
+ newDelegateWithObject: (id)anObject withUserInfo: (void*)userInfo
{
	return [[MPGraphical alloc] initWithObject: anObject withSceneManager: (ISceneManager *)userInfo];
}

- init
{
	NSAssert(0, @"MPGraphical: init call!");
	return nil;
}
- initWithObject: (id)anObject withSceneManager: (ISceneManager *)smgr
{
	[super init];
	//TODO

	nodeStrategy = nil; // Yes, it's correct. Strategey will be defined in setFeature;
	sceneManager = smgr;
	sceneManager->grab();

	return self;
}
- (void) dealloc
{
	//TODO
	sceneManager->drop();
	[nodeStrategy release];	

	[super dealloc];
}

- (void) setFeature: (NSString *)name toValue: (id<MPVariant>)dt userInfo: (NSDictionary *)info
{
	//TODO

	/*
	 * For Node strategy creation:
	 * 1) lock
	 * 2) genID
	 * 3) createStrategy object and init it unless existing strategy has a same type
	 * 4) Synchronize with existing parts of MPIrr2DObject protocol!!!
	 * 5) unlock
	 */

	[nodeStrategy setFeature: name toValue: dt userInfo: info];

	// TODO
}

- (BOOL) isVisible
{
	return [nodeStrategy isVisible];
}
- (void) setVisible: (BOOL)vis
{
	[nodeStrategy setVisible: vis];
}

- (double) getX
{
	return [nodeStrategy getX];
}
- (double) getY
{
	return [nodeStrategy getY];
}
- (unsigned) getZOrder
{
	return [nodeStrategy getZOrder];
}

- (double) getRoll
{
	return [nodeStrategy getRoll];
}

- (double) getXScale
{
	return [nodeStrategy getXScale];
}
- (double) getYScale
{
	return [nodeStrategy getYScale];
}

- (void) setXY: (double)aX : (double)aY
{

	[nodeStrategy setXY: aX : aY];
}
- (void) setZOrder: (unsigned)aZo
{
	[nodeStrategy setZOrder: aZo];
}
- (void) setRoll: (double)aR
{
	[nodeStrategy setRoll: aR];
}

- (void) setScaleXY: (double)aX : (double)aY
{
	[nodeStrategy setScaleXY: aX : aY];
}

- (void) moveByXY: (double)aX : (double)aY
{
	double x = [self getX], y = [self getY];
	[nodeStrategy setXY: x+aX : y+aY];
}

/** if objh == 0  then sprite willn't be attached or will be deattached 
 		objh - handle of object in object system; if pointed object doesn't have feature then nothing happens */
- (void) attachTo: (MPHandle)objh
{
	//TODO
	//LOCK!!!
}

- (NSUInteger) getInternalID
{
	return [nodeStrategy getSceneNode]->getID();
}
@end
