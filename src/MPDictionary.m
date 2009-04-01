#import <MPDictionary.h>
#import <dictionary.h>
#import <string.h>
#import <error_names.h>
#import <common.h>
#import <MPStringToCStringConverter.h>

/** Enumerator for MPDictionary and MPMutableDictionary. Interface is identical for NSEnumerator */
@interface MPDictionaryEnumerator : NSEnumerator
{
	dict_enumerator enumerator;
	unsigned dictionary_size;
	unsigned step;
}
/** Returns all objects that are still not enumerated; Enumerator sets to end of dictionary */
- (NSArray *) allObjects;
/** Returns current object and moves enumerator 1 position closer to end */
- (id) nextObject;

/** Initializes enumerator as NULL enumerator. Useless NULL enumerator. */
- init;
/** Initializes enumerator and configures it to enumerate keys of given c-dictionary */
- initWithCDictionaryAsKeyEnumerator: (MPCDictionary)newdict;
/** Initializes enumerator and configures it to enumerate values of given c-dictionary */
- initWithCDictionaryAsValueEnumerator: (MPCDictionary)newdict;
/** Deallocates reciever */
- (void) dealloc;

@end

/*
An example how you should NOT do: 

void DictionaryEnumeratorFunction(char *val, void *tag)
{
	DictionaryEnumeratorData ***data;
	data = (DictionaryEnumeratorData***) tag;

	(**data) = malloc(sizeof(DictionaryEnumeratorData));
	(**data)->val = malloc(0);
	strcpy((**data)->val, val);
	(**data)->next = NULL;
	*data = &((**data)->next);
}
*/

#define MP_NSSTRING_CHECK(x) \
	NSAssert(x, @"Parameter \""#x"\" is nil");\
	NSAssert([x isKindOfClass: [NSString class]], @"Parameter \""#x"\" must be NSString");

@implementation MPDictionaryEnumerator

-(NSArray *) allObjects
{
	NSMutableArray *objs;
	objs = [[[NSMutableArray alloc] initWithCapacity: dictionary_size-step] autorelease];

	char const *c;
	while ((c = (dict_enumerator_next(enumerator))) != NULL )
	{
		[objs addObject: [NSString stringWithUTF8String: c]];
	}

	return objs;
}

-(id) nextObject
{
	char const *v;
	if (!(v = dict_enumerator_next(enumerator)))
	{
		return nil;
	}
	++step;
	NSString *str;
	str = [NSString stringWithUTF8String: v];
	return str;
}

- init
{
	[super init];
	enumerator = NULL;
	dictionary_size = 0;
	step = 0;
	return self;
}

- initWithCDictionaryAsKeyEnumerator: (MPCDictionary)newdict
{
	[self init];
	dictionary_size = dict_size(newdict);
	enumerator = dict_get_keyenumerator(newdict);
	return self;
}

- initWithCDictionaryAsValueEnumerator: (MPCDictionary)newdict
{
	[self init];
	dictionary_size = dict_size(newdict);
	enumerator = dict_get_valueenumerator(newdict);
	return self;
}

- (void) dealloc
{
	dict_free_enumerator(enumerator);
	[super dealloc];
}

@end


@implementation MPDictionary

+ newDictionary
{
	return [[MPDictionary alloc] init];
}

- (id) objectForKey: (id)aKey
{
	MP_NSSTRING_CHECK(aKey);
	NSString *str;
	str = nil;
	char const *val;
	val = dict_find(dict, [valconv stringToCStr: aKey]);
	if (val)
	{
		str = [NSString stringWithUTF8String: val];
	}
	return str;
}

- (NSUInteger) count
{
	return dict_size(dict);
}

- (id) initWithObjects: (id *)objects
		       forKeys: (id *)keys
				 count: (unsigned)count
{
	[super init];
	valconv = [[MPStringToCStringConverter alloc] initWithCapacity: 5];
	kconv = [[MPStringToCStringConverter alloc] initWithCapacity: 5];
	dict = dict_getempty();
	unsigned i;
	for (i=0; i<count; ++i)
	{
		MP_NSSTRING_CHECK(objects[i]);
		MP_NSSTRING_CHECK(keys[i]);
		dict_insert(dict, [kconv stringToCStr: keys[i]], [valconv stringToCStr: objects[i]]);
	}
	dict_close(dict);
	return self;
}

- (NSEnumerator *) keyEnumerator
{
	return [[[MPDictionaryEnumerator alloc] initWithCDictionaryAsKeyEnumerator: dict] autorelease];
}

- (NSEnumerator *) objectEnumerator
{
	return [[[MPDictionaryEnumerator alloc] initWithCDictionaryAsValueEnumerator: dict] autorelease];
}

- (MPCDictionary) getCDictionary
{
	return dict;
}

- (id) copy
{
	return [self retain];
}

- (id) mutableCopy
{
	return [[MPMutableDictionary alloc] initWithCDictionary: dict];
}

- init
{
	[super init];
	kconv = nil;
	valconv = [[MPStringToCStringConverter alloc] initWithCapacity: 5];
	dict = NULL;
	dictowning = YES;
	return self;
}

- initWithCDictionary: (MPCDictionary)newDict 
{
	[self init];
	dict = newDict;
	dictowning = NO;
	dict_close(dict);
	return self;
}

- (void) dealloc
{
	[valconv release];
	[kconv release];
	if (dictowning)
	{
		dict_free(dict);
	}
	[super dealloc];
}

@end

@implementation MPMutableDictionary

+ newDictionary
{
	return [[MPMutableDictionary alloc] init];
}

- (id) objectForKey: (id)aKey
{
	MP_NSSTRING_CHECK(aKey);
	NSString *str;
	str = nil;
	char const *val;
	val = dict_find(dict, [valconv stringToCStr: aKey]);
	if (val)
	{
		str = [NSString stringWithCString: val];
	}
	return str;
}

- (void) setObject: (id)anObject forKey: (id)aKey
{
	MP_NSSTRING_CHECK(aKey);
	MP_NSSTRING_CHECK(anObject);
	dict_insert(dict, [valconv stringToCStr: aKey], [objconv stringToCStr: anObject]);
}

- (void) removeObjectForKey: (id)aKey
{
	MP_NSSTRING_CHECK(aKey);
	dict_remove(dict, [valconv stringToCStr: aKey]);
}

- (void) removeAllObjects
{
	dict_clear(dict);
}

- (NSUInteger) count
{
	return dict_size(dict);
}

- (id) initWithObjects: (id *)objects
		       forKeys: (id *)keys
				 count: (unsigned)count
{
	[self init];
	unsigned i;
	for (i=0; i<count; ++i)
	{
		[self setObject: objects[i] forKey: keys[i]];
	}
	return self;
}

- (NSEnumerator *) keyEnumerator
{
	return [[[MPDictionaryEnumerator alloc] initWithCDictionaryAsKeyEnumerator: dict] autorelease];
}


- (NSEnumerator *) objectEnumerator
{
	return [[[MPDictionaryEnumerator alloc] initWithCDictionaryAsValueEnumerator: dict] autorelease];
}

- (MPCDictionary) getCDictionary
{
	return dict;
}

- (id) mutableCopy
{
	MPMutableDictionary *new;
	new = [[MPMutableDictionary alloc] initWithCDictionary: dict];
	return new;
}

- (id) copy
{
	MPMutableDictionary *new;
	new = [[MPMutableDictionary alloc] initWithCDictionary: dict];
	dict_close(new->dict);
	return new;
}

- init
{
	[self initWithCDictionary: NULL];
	return self;
}

- initWithCDictionary: (MPCDictionary)newDict
{
	valconv = [[MPStringToCStringConverter alloc] initWithCapacity: 5];
	objconv = [[MPStringToCStringConverter alloc] initWithCapacity: 5];
	[super init];
	if (newDict)
	{
		dict = newDict;
		dictowning = NO;
	}
	else
	{
		dict = dict_getempty(newDict);
		dictowning = YES;
	}
	return self;
}

- (id) initWithCapacity: (unsigned)numItems
{
	return [self init];
}

- (void) dealloc
{
	[valconv release];
	[objconv release];
	if (dictowning)
	{
		dict_free(dict);
	}
	[super dealloc];
}

@end

