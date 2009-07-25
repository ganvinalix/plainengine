#import <MPResultCradle.h>

@implementation MPResultCradle
- init
{
	[super init];
	_result = nil;
	_mutex = [NSRecursiveLock new];
	return self;
}
- (void) dealloc
{
	[self setResult: nil];
	[_mutex release];
	[super dealloc];
}
+ resultCradle
{
	return [[MPResultCradle new] autorelease];
}

- (id<MPVariant>) getResult
{
	[_mutex lock];
	id<MPVariant> tmp = [[_result retain] autorelease];
	[_mutex unlock];

	return tmp;
}
- (void) setResult: (id<MPVariant>)aResult
{
	if(_result != aResult)
	{
		[_mutex lock];
		[_result release];
		_result = [aResult retain];
		[_mutex unlock];
	}
}
@end

