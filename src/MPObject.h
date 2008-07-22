#import <Foundation/Foundation.h>
#import <MPFeature.h>

@interface MPBaseObject : NSObject
	// etc...
@end

// i think this class will be always mutable (nekro)
@interface MPObject : MPBaseObject /*< NSCopying, NSMutableCopying, NSCoding > */
	// representation in world ( id<MPBaseObject> repr, access functions )
	// composite stuff (iterators, children managment, owner managment)
		///!!! is NSMutableArray NSutableCopying???
	// NSCopying, MutableCopying
	// NSCoding
	// Features stuff ( add/remove, (MPFeature*)getFeatureBy[Id/Name], (NSSet) getFeatures, isA(feature[id/name]) )
@end
