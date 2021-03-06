#import <Foundation/Foundation.h>

typedef id (*converterFunction)(id);

/** 
  *	<p>This class is created for optimiztion of memory (and CPU time) usage, when there is
  * a neccesarity for often conversions between two types.</p>
  * <p>For example, you need to convert NSNumber to NSString, but if you would call [number stringValue],
  * there will be too many of strings in autorelease pool.</p>
  * <p>The solution is to declare a converterFunction:</p>
  * 
  * <example>
  * id numberToString(id number)
  * {
  * 	return [number stringValue];
  * 	//Note that return value must not be retained to avoid memory leak;
  * } </example>
  *
  * <p>...create MPMapper:</p>
  *
  * <example>MPMapper *numToStrMapper = [[MPMapper alloc] initWithConverter: &amp;numberToString];</example>
  *
  * <p>...and when you would need to convert 'num' to 'str' call:</p>
  *
  * <example>str = [numToStrMapper getObject: num];</example>
  *
  * <p>Mapper caches all used keys and objects, and when key is reused, it just returns already counted string.</p>
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

