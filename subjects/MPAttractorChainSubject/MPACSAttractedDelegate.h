#import <Foundation/Foundation.h>
#import <MPCore.h>

extern double attractingImpulseCoefficient;
extern double attractingRadius;

@interface MPACSAttractedDelegate : NSObject
{
	id<MPObject> connectedObject;
}

+(void)setAPI: (id<MPAPI>)api;
+newDelegateWithObject: (id<MPObject>)object;

-initDelegateWithObject: (id<MPObject>)object;

-(void)setFeature: (NSString *)name toValue: (id<MPVariant>)value;
-(void)removeFeature: (NSString *)name;

@end

