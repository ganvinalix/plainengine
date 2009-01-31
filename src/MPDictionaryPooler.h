#import <Foundation/Foundation.h>

@interface MPDictionaryPooler : NSObject
{
	NSMutableDictionary *poolDict;
}

-init;
-newDictionaryForKeys: (NSSet *)keys;
-(void) dealloc;

@end

