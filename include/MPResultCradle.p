#import <Foundation/Foundation.h>
#import <MPVariant.p>

@protocol MPResultCradle
/** returns result, or nil if result still not ready*/
- (id<MPVariant>) getResult;
/** sets aResult as value if it isn't nil*/
- (void) setResult: (id<MPVariant>)aResult;
@end

