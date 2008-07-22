#import <Foundation/Foundation.h>

typedef unsigned long feature_id_t;
#define NOT_FEATURE ( (feature_id_t)(-1) )

@protocol MPFeature /*< NSCopying >*/
- (NSString *) name;

- (NSString *) typeName;
- (feature_id_t) typeId;

// something another...
@end

