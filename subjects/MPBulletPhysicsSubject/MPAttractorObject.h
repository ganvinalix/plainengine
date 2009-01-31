#import <MPGhostObject.h>

@interface MPAttractorObject: MPGhostObjectDelegate
{
	NSMutableArray *attractedObjects;
}

+(void) updateWorldWithAPI: (id<MPAPI>)api byTime: (double)time;
+(void) setWorld: (btDynamicsWorld *)world;

-initWithObject: (id<MPObject>)object;

-(void) setFeature: (NSString *)featureName toValue: (id<MPVariant>)data userInfo: (id)userInfo;
-(void) removeFeature: (NSString *)featureName;

-(btGhostObject *) getAttractorObject;

-(void) dealloc;

@end

