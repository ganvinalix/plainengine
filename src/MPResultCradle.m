#import <MPResultCradle.h>

@implementation MPResultCradle
- init
{
	[super init];
	_result = nil;
	return self;
}
- (void) dealloc
{
	[self setResult: nil];
	[super dealloc];
}
+ resultCradle
{
	return [[MPResultCradle new] autorelease];
}

- (id<MPVariant>) getResult
{
	return [[_result retain] autorelease];
}
- (void) setResult: (id<MPVariant>)aResult
{
	if(_result)
	{
		[_result release];
		_result = nil;
	}
	if(aResult)
	{
		_result = [aResult retain];
	}
}
@end

