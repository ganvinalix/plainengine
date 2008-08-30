#import <MPDictionary.h>
#import <MPCodeTimer.h>
#import <dictionary.h>
#import <string.h>
#import <error_names.h>

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
	if (![[x class] isSubclassOfClass: [NSString class]])\
	{\
		NSException *exc = [NSException exceptionWithName: MPIsNotNSString\
						reason: @"Parameter \""#x"\" must be NSString"\
						userInfo: nil];\
		@throw exc;\
	}


@implementation MPDictionaryEnumerator

-(NSArray *) allObjects
{
	NSMutableArray *objs;
	objs = [[[NSMutableArray alloc] initWithCapacity: dictionary_size-step] autorelease];

	char *c;
	while ((c = (dict_enumerator_next(enumerator))) != NULL )
	{
		[objs addObject: [NSString stringWithUTF8String: c]];
	}

	return objs;
}

-(id) nextObject
{
	char *v;
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

- (id) objectForKey: (id)aKey
{
	MP_NSSTRING_CHECK(aKey);
	char *buf;
	NSString *str;
	str = nil;
	if (dict_find(dict, [aKey UTF8String], buf))
	{
		str = [NSString stringWithUTF8String: buf];
	}
	free(buf);
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
	dict = dict_getempty();
	unsigned i;
	for (i=0; i<count; ++i)
	{
		MP_NSSTRING_CHECK(objects[i]);
		MP_NSSTRING_CHECK(keys[i]);
		dict_insert(dict, [keys[i] UTF8String], [objects[i] UTF8String]);
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

- (dictionary *) getCDictionary
{
	return dict;
}

- (id) copy
{
	return [self retain];
}

- (id) mutableCopy
{
	MPMutableDictionary *new;
	new = [[MPMutableDictionary alloc] initWithCDictionary: dict];
	return new;
}

- init
{
	[super init];
	dict = NULL;
	return self;
}

- initWithCDictionary: (dictionary *)newDict 
{
	[super init];
	dict = dict_copy(newDict);
	return self;
}

- (void) dealloc
{
	dict_free(dict);
	[super dealloc];
}

@end

@implementation MPMutableDictionary

- (id) objectForKey: (id)aKey
{
	MP_NSSTRING_CHECK(aKey);
	char *buf;
	buf = malloc(0);
	NSString *str;
	str = nil;
	if (dict_find(dict, [aKey UTF8String], buf))
	{
		str = [NSString stringWithUTF8String: buf];
	}
	free(buf);
	return str;
}

- (void) setObject: (id)anObject forKey: (id)aKey
{
	MP_NSSTRING_CHECK(anObject);
	MP_NSSTRING_CHECK(aKey);
	dict_insert(dict, [aKey UTF8String], [anObject UTF8String]);
}

- (void) removeObjectForKey: (id)aKey
{
	MP_NSSTRING_CHECK(aKey);
	dict_remove(dict, [aKey UTF8String]);
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

- (dictionary *) getCDictionary
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
	[super init];
	dict = dict_getempty();
	return self;
}

- initWithCDictionary: (dictionary *)newDict
{
	[super init];
	dict = dict_copy(newDict);
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

