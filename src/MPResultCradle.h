#import <Foundation/Foundation.h>
#import <MPResultCradle.p>

@interface MPResultCradle : NSObject <MPResultCradle>
{
@private
	id<MPVariant> _result;
}
+ resultCradle;
@end


