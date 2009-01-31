#import <MPPool.h>

@implementation MPPool

-init
{
	NSAssert(NO, @"Pool created without class");
	return nil;
}

-initWithClass: (Class)aClass
{
	[super init];
	pooledObjects = [[NSMutableArray alloc] init];
	pclass = aClass;
	return self;
}

-(id) newObject
{
	NSUInteger i, size;
	size = [pooledObjects count];
	for (i=0; i<size; ++i)
	{
		id obj = [pooledObjects objectAtIndex: i];
		if ([obj retainCount]==1)
		{
			return [obj retain];
		}
	}
	id obj;
	obj = [pclass new];
	[pooledObjects addObject: obj];
	return obj;
}

-(void) purge
{
	[pooledObjects removeAllObjects];
}

-(NSUInteger) size
{
	return [pooledObjects count];
}

-(void) prepare: (NSUInteger)count
{
	NSUInteger i, c;
	c = count - [self size];
	for (i=0; i<c; ++i)
	{
		id obj = [pclass new];
		[pooledObjects addObject: obj];
		[obj release]; //pooledObjects is new obj owner
	}
}

-(void) dealloc
{
	[pooledObjects release];
	[super dealloc];
}


@end

