#import <Foundation/Foundation.h>
#import <dictionary.h>
#import <common.h>

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

- (NSUInteger) count;
- (id) objectForKey: (id)aKey;

- (NSEnumerator*) keyEnumerator;
- (NSEnumerator*) objectEnumerator;

- (id) mutableCopy;
- (id) copy;

- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
		 count: (unsigned)count;
- init;
- initWithCDictionary: (dictionary*)newDict shouldCopy: (BOOL)shouldCopy;
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

- (NSUInteger) count;
- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
		 count: (unsigned)count;
- (NSEnumerator*) keyEnumerator;
- (NSEnumerator*) objectEnumerator;

- (dictionary*) getCDictionary;

- (id) mutableCopy;
- (id) copy;

- init;
- initWithCDictionary: (dictionary*)newDict shouldCopy: (BOOL)shouldCopy;
- (id) initWithCapacity: (unsigned)numItems;
- (void) dealloc;

@end

