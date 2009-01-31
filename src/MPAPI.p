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

#define MP_HANDLER_OF_MESSAGE(messageName) 		- (void) _h_msg_##messageName: (MPCDictionaryRepresentable *) anUserInfo
#define MP_HANDLER_OF_REQUEST(requestName)		- (void) _h_req_##requestName: (MPCDictionaryRepresentable *) anUserInfo result: (id<MPResultCradle>)aResult
#define MP_HANDLER_OF_ANY_MESSAGE				- (void) _h_messageWithName: (NSString* )aName userInfo:(MPCDictionaryRepresentable *) anUserInfo

#define MP_MESSAGE_DATA anUserInfo 
#define MP_MESSAGE_NAME aName
#define MP_SET_RESULT(x) [aResult setResult: x];

