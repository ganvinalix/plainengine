#import <Foundation/Foundation.h>
#import <common.h>

@interface MPAssertionHandler: NSAssertionHandler
{

}
-(void) handleFailureInFunction: (NSString *)functionName file: (NSString *)fileName lineNumber: (NSInteger)line description: (NSString *)format, ...;
-(void) handleFailureInMethod: (SEL)selector object: (id)object file: (NSString *)fileName lineNumber: (NSInteger)line description: (NSString *)format, ...;

@end

