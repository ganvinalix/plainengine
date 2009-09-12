#import <MPPair.h>

@implementation MPPair

-init
{
	return [self initWithObject1: nil withObject2: nil];
}

-initWithObject1: (id)obj1 withObject2: (id)obj2
{
	[super init];
	firstObject=secondObject=nil;
	[self setObject1: obj1 object2: obj2];
	return self;
}

-copyWithZone: (NSZone *)zone
{
	return [[MPPair allocWithZone: zone] initWithObject1: firstObject withObject2: secondObject];
}

-(void) setObject1: (id)obj1 object2: (id)obj2
{
	//previous objects in pair must be released after new objects will be retained
	//because one of new objects may be also an one of old objects
	id oldFirstObject=firstObject, oldSecondObject=secondObject;

	NSUInteger obj1hash = [obj1 hash], obj2hash = [obj2 hash];
	if (obj1hash<obj2hash)
	{
		firstObject = [obj1 retain];
		secondObject = [obj2 retain];
		firstHash = obj1hash;
		secondHash = obj2hash;
	}
	else
	{
		firstObject = [obj2 retain];
		secondObject = [obj1 retain];
		firstHash = obj2hash;
		secondHash = obj1hash;
	}
	hashcollision = obj1hash==obj2hash;
	[oldFirstObject release];
	[oldSecondObject release];
}

-(id) getFirstObject
{
	return firstObject;
}

-(id) getSecondObject
{
	return secondObject;
}

-(NSUInteger) hash
{
	return firstHash + secondHash;
}

-(BOOL) isEqual: (id)anObject
{
	if (![anObject isKindOfClass: [MPPair class]])
	{
		return NO;
	}
	else if (!hashcollision)
	{
		MPPair *anObjectAsPair = anObject;
		return ([anObjectAsPair->firstObject isEqual: firstObject]) && ([anObjectAsPair->secondObject isEqual: secondObject]);
	}
	else
	{
		MPPair *anObjectAsPair = anObject;
		if (([anObjectAsPair->firstObject isEqual: firstObject]) && ([anObjectAsPair->secondObject isEqual: secondObject]))
		{
			return YES;
		}
		if (([anObjectAsPair->firstObject isEqual: secondObject]) && ([anObjectAsPair->secondObject isEqual: firstObject]))
		{
			return YES;
		}
	}
	return NO;
}

-(void) dealloc
{
	[firstObject release];
	[secondObject release];
	[super dealloc];
}

@end

