#import <Foundation/Foundation.h>
#import <numeric_types.h>

typedef id (*converterFunction)(id);

/**
  *	This class is created for optimiztion of memory (and CPU time) usage, when there is
  * a neccesarity for often conversions between two types.
  * For example, you need to convert NSNumber to NSString, but if you would call [number stringValue],
  * there will be too many of strings in autorelease pool.
  * The solution is to declare a converterFunction:
  *
  * id numberToString(id number)
  * {
  * 	return [number stringValue];
  * 	//Note that return value must not be retained to avoid memory leak;
  * }
  *
  * ...create MPMapper:
  *
  * MPMapper *numToStrMapper = [[MPMapper alloc] initWithConverter: &numberToString];
  *
  * ...and when you would need to convert 'num' to 'str' call:
  *
  * str = [numToStrMapper getObject: num];
  *
  * Mapper caches all used keys and objects, and when key is reused, it just returns already counted string.
  */
@interface MPMapper : NSObject
{
	NSMutableDictionary *map;
	converterFunction conv;
}

-init; //error
-initWithConverter: (converterFunction)func;

-(id) getObject: (id)key;

-(NSUInteger) size;
-(void) purge;

-(void) dealloc;

@end

