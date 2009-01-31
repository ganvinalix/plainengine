#import <MPDictionaryPooler.h>
#import <MPDictionary.h>
#import <MPUtility.h>

@implementation MPDictionaryPooler

-init
{
	poolDict = [[NSMutableDictionary alloc] init];
	return [super init];
}

-newDictionaryForKeys: (NSSet *)keys
{
	MPPool *pool;
	pool = [poolDict objectForKey: keys];
	if (pool)
	{
		return [pool newObject];
	}
	else
	{
		pool = [[MPPool alloc] initWithClass: [MPMutableDictionary class]];
		[poolDict setObject: pool forKey: keys];
		[pool release];
		return [pool newObject];
	}
}

-(void) dealloc
{
	[poolDict release];
	[super dealloc];
}

@end

