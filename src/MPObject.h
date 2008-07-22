#import <Foundation/Foundation.h>
#import <MPFeature.h>

@protocol MPPositon
	// xyz
@end

@protocol MPOrientation
	// rx, ry, rz (quaternion)
@end

@protocol MPSize
	// sz, sy, sz
@end

@protocol MPBaseObject < MPPositon, MPOrientation, MPSize >
	// etc...
@end

@interface MPObject : NSObject < MPBaseObject/*NSCopying, NSMutableCopying, NSCoding*/ > 
	// representation in world ( id<MPBaseObject> repr, access functions )
	// composite stuff (iterators, children managment, owner managment)
	// NSCopying, MutableCopying
	// NSCoding
	// Features stuff ( add/remove, (MPFeature*)getFeatureBy[Id/Name], (NSSet) getFeatures, isA(feature[id/name]) )
@end
