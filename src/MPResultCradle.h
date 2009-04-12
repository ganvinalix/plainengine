#import <Foundation/Foundation.h>
#import <MPResultCradle.p>

@interface MPResultCradle : NSObject <MPResultCradle>
{
@private
	id<MPVariant> _result;
	NSLock *_mutex;
}
+ resultCradle;
@end


