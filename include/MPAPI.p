#import <Foundation/Foundation.h>
#import <MPObject.p>
#import <MPResultCradle.p>
#import <MPDictionary.p>
#import <MPLog.p>

@protocol MPAPI <NSObject>
- (void) yield;
- (void) postMessageWithName: (NSString *)aName;
- (void) postMessageWithName: (NSString *)aName userInfo: (MPCDictionaryRepresentable *)anUserInfo;
- (id<MPVariant>) postRequestWithName: (NSString *)aName;
- (id<MPVariant>) postRequestWithName: (NSString *)aName userInfo: (MPCDictionaryRepresentable *)anUserInfo;
- (Class<MPObject>) getObjectSystem;
- (id<MPLog>) log;
@end

