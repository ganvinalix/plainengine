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
	//Yes, it's correct. Strategey will be defined in setFeature;
	nodeStrategy = nil;

	return self;
}
- (void) dealloc
{
	//TODO
	[nodeStrategy release];	

	[super dealloc];
}

- (void) setFeature: (NSString *)name toValue: (id<MPVariant>)dt userInfo: (NSDictionary *)info
{
	//TODO
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
	//LOCK???
	return [nodeStrategy getInternalID];
}
@end
