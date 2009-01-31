#import <Foundation/Foundation.h>
#import <btBulletDynamicsCommon.h>

double getDoubleValueFromDictionary(id dict, NSString *name, double def);
int getIntValueFromDictionary(id dict, NSString *name, int def);
btCollisionShape *getShape(id dict);

#define MPBPS_LOAD_DOUBLEVALUE_FROMDICTIONARY(dict, nam, def)\
		double nam = getDoubleValueFromDictionary(dict, @#nam, def);

#define MPBPS_LOAD_INTVALUE_FROMDICTIONARY(dict, nam, def)\
		int nam = getIntValueFromDictionary(dict, @#nam, def);

@interface MPUIntWrapper : NSObject
{
	NSUInteger value;
}
-init;
-(NSUInteger) getValue;
-(void) setValue: (NSUInteger)val;
-(void) inc;
@end

