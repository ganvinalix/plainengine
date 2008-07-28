#import <Foundation/Foundation.h>
#import <dictionary.h>

@interface MPDictionaryEnumerator : NSEnumerator
{
	dict_enumerator *enumerator;
	unsigned long dictionary_size;
}
-(NSArray*) allObjects;
-(id) nextObject;

- init;
- initWithCDictionaryAsKeyEnumerator: (dictionary*)newdict;
- initWithCDictionaryAsValueEnumerator: (dictionary*)newdict;
- (void) dealloc;
@end;

@interface MPMutableDictionary : NSMutableDictionary
{
@private
	dictionary *dict;
}

- (id) objectForKey: (id)aKey;
- (void) setObject: (id)anObject forKey: (id)aKey;
- (void) removeObjectForKey: (id)aKey;

- (unsigned) count;
- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
		 count: (unsigned)count;
- (NSEnumerator*) keyEnumerator;
- (NSEnumerator*) objectEnumerator;

- (dictionary*) getCDictionary;

- init;
- (void) dealloc;

@end

