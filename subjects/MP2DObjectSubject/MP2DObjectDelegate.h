#import <MP2DObject.p>
#import <MPCore.h>

@interface MP2DObjectDelegate : NSObject <MP2DObject>
{
	double x, y, sx, sy, roll;
	unsigned z_order;

	NSLock *_lock;
	id<MPObject, MP2DObject> _object;
}
+ newDelegateWithObject: (id<MPObject>)object;
@end

