#import <MPDictionary.h>
#import <dictionary.h>
#import <malloc.h>
#import <string.h>

/*
void DictionaryEnumeratorFunction(char *val, void *tag)
{
	DictionaryEnumeratorData ***data;
	data = (DictionaryEnumeratorData***) tag;

	(**data) = malloc(sizeof(DictionaryEnumeratorData));
	(**data)->val = malloc(1);
	strcpy((**data)->val, val);
	(**data)->next = NULL;
	*data = &((**data)->next);
}
*/

@implementation MPDictionaryEnumerator

-(NSArray*) allObjects
{
	NSMutableArray *objs;
	objs = [[[NSMutableArray alloc] initWithCapacity: dictionary_size] autorelease];
	dict_enumerator_store_type stamp;
	stamp = dict_store_enumerator(enumerator);

	char *c;
	while ((c = (dict_enumerator_next(enumerator))) != NULL )
	{
		[objs addObject: [NSString stringWithUTF8String: c]];
	}
	dict_restore_enumerator(stamp, enumerator);

	return objs;
}

-(id) nextObject
{
	char *v;
	if (!(v = dict_enumerator_next(enumerator)))
	{
		return nil;
	}
	NSString *str;
	str = [NSString stringWithUTF8String: v];
	return str;
}

- init
{
	[super init];
	enumerator = NULL;
	dictionary_size = 0;
	return self;
}

- initWithCDictionaryAsKeyEnumerator: (dictionary*)newdict
{
	[self init];
	dictionary_size = dict_size(newdict);
	enumerator = dict_get_keyenumerator(newdict);
	return self;
}

- initWithCDictionaryAsValueEnumerator: (dictionary*)newdict
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

- (dictionary*) getCDictionary
{
	dictionary *dict;
	dict = dict_getempty();


	NSEnumerator *enumer;
	NSString *str;
	enumer = [self keyEnumerator];
	while ((str = [enumer nextObject]) != nil)
	{
		dict_insert(dict, [str UTF8String], [[self objectForKey: str] UTF8String]);
	}
	dict_close(dict);

	return dict;
}

- init
{
	return [super init];
}

- (void) dealloc
{
	[super dealloc];
}

@end

@implementation MPMutableDictionary

- (id) objectForKey: (id)aKey
{
	char *buf, *key;
	buf = malloc(1);
	key = [aKey UTF8String];
	NSString* str;
	str = nil;
	if (dict_find(dict, key, buf))
	{
		str = [NSString stringWithUTF8String: buf];
	}
	free(buf);
	return str;
}

- (void) setObject: (id)anObject forKey: (id)aKey
{
	char *key, *value;
	key = [aKey UTF8String];
	value = [anObject UTF8String];
	dict_insert(dict, key, value);
}

- (void) removeObjectForKey: (id)aKey
{
	char *key;
	key = [aKey UTF8String];
	dict_remove(dict, key);
}

- (unsigned) count
{
	return dict_size(dict);
}

- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
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

- (NSEnumerator*) keyEnumerator
{
	return [[[MPDictionaryEnumerator alloc] initWithCDictionaryAsKeyEnumerator: dict] autorelease];
}


- (NSEnumerator*) objectEnumerator
{
	return [[[MPDictionaryEnumerator alloc] initWithCDictionaryAsValueEnumerator: dict] autorelease];
}

- (dictionary*) getCDictionary
{
	return dict;
}

- init
{
	[super init];
	dict = dict_getempty();
	return self;
}

- (id) initWithCapacity: (unsigned)numItems
{
	return [self init];
}

- (void) dealloc
{
	dict_free(dict);
	[super dealloc];
}

@end

