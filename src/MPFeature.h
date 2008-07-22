#import <Foundation/Foundation.h>

typedef unsigned long feature_id_t;
#define NOT_FEATURE ( (feature_id_t)(-1) )

@protocol MPFeatureData /*< NSCopying, NSCoding >*/
// it's just a dummmy now
@end

@protocol MPFeature /*< NSCopying, NSCoding >*/
// returns array of objects with this feature
- (NSArray *) getObjects;
// in @intefrace also addObject or something similiar needs
// information
/// name
- (NSString *) name;
///type
- (NSString *) typeName;
- (feature_id_t) typeId;

// feature data access
- (id <MPFeatureData>) data; // dictionary + struct + sync

// something another...
@end

