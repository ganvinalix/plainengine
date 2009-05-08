#import <MPAssertionHandler.h>

@implementation MPAssertionHandler

-(void) handleFailureInFunction: (NSString *)functionName file: (NSString *)fileName lineNumber: (NSInteger)line description: (NSString *)format, ...
{
	va_list arglist;
	va_start(arglist, format);
	NSString *buffer = [[[NSString alloc] initWithFormat: format arguments: arglist] autorelease];
	va_end(arglist);
	NSString *message = [NSString stringWithFormat: @"Assertion failed in function \"%@\" (%@:%lu) with message: \"%@\".", functionName, fileName, line, buffer];
	[gLog add: critical withFormat: @"%@", message];
}

-(void) handleFailureInMethod: (SEL)selector object: (id)object file: (NSString *)fileName lineNumber: (NSInteger)line description: (NSString *)format, ...
{
	va_list arglist;
	va_start(arglist, format);
	NSString *buffer = [[[NSString alloc] initWithFormat: format arguments: arglist] autorelease];
	va_end(arglist);
	NSString *message = [NSString stringWithFormat: @"Assertion failed in method [%@ %@] (%@:%lu) of object \"%@\" with message: \"%@\".",
			 NSStringFromClass([object class]), NSStringFromSelector(selector), fileName, line, object, buffer];
	[gLog add: critical withFormat: @"%@", message];
}

@end

void MPBindAssertionHandlerToThread(NSThread *thread)
{
	[[thread threadDictionary] setObject: [[MPAssertionHandler new] autorelease] forKey: @"NSAssertionHandler"];
}

