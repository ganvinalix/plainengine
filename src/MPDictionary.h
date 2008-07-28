#import <Foundation/Foundation.h>
#import <dictionary.h>

@interface MPDictionaryEnumerator : NSEnumerator
{
	dict_enumerator *enumerator;
	unsigned dictionary_size;
	unsigned step;
}
- (NSArray*) allObjects;
- (id) nextObject;

- init;
- initWithCDictionaryAsKeyEnumerator: (dictionary*)newdict;
- initWithCDictionaryAsValueEnumerator: (dictionary*)newdict;
- (void) dealloc;

@end;

@interface MPDictionary : NSDictionary
{
@private
	dictionary *dict;
}

- (dictionary*) getCDictionary;

- (unsigned) count;
- (id) objectForKey: (id)aKey;

- (NSEnumerator*) keyEnumerator;
- (NSEnumerator*) objectEnumerator;

- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
		 count: (unsigned)count;
- init;
- (void) dealloc;

@end

@interface MPMutableDictionary : NSMutableDictionary
{
@private
	dictionary *dict;
}

- (id) objectForKey: (id)aKey;
- (void) setObject: (id)anObject forKey: (id)aKey;
- (void) removeObjectForKey: (id)aKey;
- (void) removeAllObjects;

- (unsigned) count;
- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
		 count: (unsigned)count;
- (NSEnumerator*) keyEnumerator;
- (NSEnumerator*) objectEnumerator;

- (dictionary*) getCDictionary;

- init;
- (id) initWithCapacity: (unsigned)numItems;
- (void) dealloc;

@end

