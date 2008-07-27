#import <Foundation/Foundation.h>
#import <dictionary.h>

typedef struct
{
	char *val;
	struct DictionaryEnumeratorData *next;

} DictionaryEnumeratorData;

@interface MPDictionaryEnumerator : NSEnumerator
{
	DictionaryEnumeratorData *enumeratorData, *currentVal;
	unsigned dictionary_size;
}
-(NSArray*) allObjects;
-(id) nextObject;

- init;
- initWithCDictionary: (dictionary*)newdict;
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

- (dictionary*) getCDictionary;

- init;
- (void) dealloc;

@end

