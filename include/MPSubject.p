#import <Foundation/Foundation.h>
#import <MPAPI.p>

@protocol MPSubject <NSObject>
- initWithString: (NSString *)string;

- (void) receiveAPI: (id<MPAPI>)anAPI;
- (void) start;
- (void) stop;
- (void) update;
@end

#define MP_HANDLER_OF_MESSAGE(messageName) 		- (void) _h_msg_##messageName: (MPCDictionaryRepresentable *) anUserInfo
#define MP_HANDLER_OF_REQUEST(requestName)		- (void) _h_req_##requestName: (MPCDictionaryRepresentable *) anUserInfo result: (id<MPResultCradle>)aResult
#define MP_HANDLER_OF_ANY_MESSAGE				- (void) _h_messageWithName: (NSString* )aName userInfo:(MPCDictionaryRepresentable *) anUserInfo

#define MP_MESSAGE_DATA anUserInfo 
#define MP_MESSAGE_NAME aName
#define MP_SET_RESULT(x) [aResult setResult: x];

