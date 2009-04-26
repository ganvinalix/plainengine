#import <Foundation/Foundation.h>

/** This class grants interface for working with pairs of objects. It supports comparison with another pair.*/
@interface MPPair : NSObject <NSCopying>
{
	id firstObject, secondObject;
	NSUInteger firstHash, secondHash;
	BOOL hashcollision;
}

-init;
-initWithObject1: (id)obj1 withObject2: (id)obj2;

-(void) setObject1: (id)obj1 object2: (id)obj2;

-(id) getFirstObject;
-(id) getSecondObject;

-(NSUInteger) hash;
-(BOOL) isEqual: (id)anObject;

-(void) dealloc;

@end

