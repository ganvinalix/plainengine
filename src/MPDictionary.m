#import <MPDictionary.h>
#import <dictionary.h>
#import <malloc.h>
#import <string.h>

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

@implementation MPDictionaryEnumerator

-(NSArray*) allObjects
{
	NSMutableArray *objs;
	objs = [[[NSMutableArray alloc] initWithCapacity: dictionary_size] autorelease];
	DictionaryEnumeratorData *en=currentVal;
	while (en)
	{
		[objs addObject: [NSString stringWithUTF8String: en->val]];
		en = en->next;
	}
	return objs;
}

-(id) nextObject
{
	if (!currentVal)
	{
		return nil;
	}
	NSString *str;
	str = [NSString stringWithUTF8String: currentVal->val];
	currentVal = currentVal->next;
	return str;
}

- init
{
	[super init];
	enumeratorData = NULL;
	currentVal = NULL;
	dictionary_size = 0;
	return self;
}

- initWithCDictionary: (dictionary*)newdict
{
	[self init];
	DictionaryEnumeratorData **data;
	data = &enumeratorData;
	dict_enumerate_keys(newdict, &data, &DictionaryEnumeratorFunction);
	currentVal = enumeratorData;
	dictionary_size = dict_size(newdict);
}

- (void) dealloc
{
	DictionaryEnumeratorData *dat;
	while (enumeratorData)
	{
		dat = enumeratorData->next;
		free(enumeratorData);
		enumeratorData = dat;
	}
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
	return [[[MPMutableDictionary alloc] initWithCDictionary: dict] autorelease];
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

- (void) dealloc
{
	dict_clear(dict);
	[super dealloc];
}

@end

