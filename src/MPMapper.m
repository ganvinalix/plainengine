#import <MPMapper.h>

@implementation MPMapper

-init
{
	NSAssert(NO, @"MPMapper created without converter");
	return nil;
}

-initWithConverter: (converterFunction)func
{
	conv = func;
	map = [[NSMutableDictionary alloc] init];
	return [super init];
}

-(id) getObject: (id)key
{
	id obj;
	obj = [map objectForKey: key];
	if (obj)
	{
		return obj;
	}
	else
	{
		obj = (*conv)(key);
		[map setObject: obj forKey: key];
		return obj;
	}
}

-(NSUInteger) size
{
	return [map count];
}

-(void) purge
{
	[map removeAllObjects];
}

-(void) dealloc
{
	[map release];
	[super dealloc];
}

@end

