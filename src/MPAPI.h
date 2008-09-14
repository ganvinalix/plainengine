#import <Foundation/Foundation.h>
#import <MPObject.h>

@protocol MPAPI
- (void) yield: (NSTimeInterval)anInterval;
- (void) postNotificationName: (NSString *)aName;
- (void) postNotificationName: (NSString *)aName userInfo: (NSDictionary *) anUserInfo;
@end

