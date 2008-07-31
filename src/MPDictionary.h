#import <Foundation/Foundation.h>
#import <dictionary.h>
#import <numeric_types.h>

/** Enumerator for MPDictionary and MPMutableDictionary. Interface is identical for NSEnumerator */
@interface MPDictionaryEnumerator : NSEnumerator
{
	dict_enumerator *enumerator;
	unsigned dictionary_size;
	unsigned step;
}
/** Returns all objects that are still not enumerated; Enumerator sets to end of dictionary */
- (NSArray*) allObjects;
/** Returns current object and moves enumerator 1 position closer to end */
- (id) nextObject;

/** Initializes enumerator as NULL enumerator. Useless NULL enumerator. */
- init;
/** Initializes enumerator and configures it to enumerate keys of given c-dictionary */
- initWithCDictionaryAsKeyEnumerator: (dictionary*)newdict;
/** Initializes enumerator and configures it to enumerate values of given c-dictionary */
- initWithCDictionaryAsValueEnumerator: (dictionary*)newdict;
/** Deallocates reciever */
- (void) dealloc;

@end;

/** Protocol which means that object can be represented as pure-C dictionary (see dictionary.h for details) */
@protocol MPCDictionaryRepresentable

/** Returns pointer to pure-C dictionary, equal to this dictionary. You must not free it when you finish! */
- (dictionary*) getCDictionary;

/** Initializes this dictionary with copy of content stored in newDict */
- initWithCDictionary: (dictionary*)newDict;

@end

/**
 * Class which repeats functions of NSDictionary except:
 * 1) Permits only NSString as keys and objects; Throws exception with name MPIsNotNSString if don't follow this;
 * 2) Has ability to get pointer to dictionary structure with elements of MPDictionary which can be used in pure-C code
 */
@interface MPDictionary : NSDictionary <MPCDictionaryRepresentable>
{
@private
	dictionary *dict;
}

/** Returns number of objects */
- (NSUInteger) count;
/** Returns object for given key */
- (id) objectForKey: (id)aKey;

/** Returns key enumertor */
- (NSEnumerator*) keyEnumerator;
/** Returns object enumertor */
- (NSEnumerator*) objectEnumerator;

/** Returns MPMutableDictionary with data equal to data stored in this dictionary */
- (id) mutableCopy;
/** Returns copy of this dictionary */
- (id) copy;

/** Initializes this dictionary with data, given in arrays keys[] and objects[] */
- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
		 count: (unsigned)count;
/** Initializes this dictionary as empty (And never it can be filled with data later) */
- init;

/** Deallocates reciever */
- (void) dealloc;

@end

/**
 * Class which repeats functions of NSMutableDictionary except:
 * 1) Permits only NSString as keys and objects; Throws exception with name MPIsNotNSString if don't follow this;
 * 2) Has ability to get pointer to dictionary structure with elements of MPDictionary which can be used in pure-C code
 * WARNING: This class isn't derived from NSDictionary!
 */
@interface MPMutableDictionary : NSMutableDictionary <MPCDictionaryRepresentable>
{
@private
	dictionary *dict;
}

/** Returns object for guven key */
- (id) objectForKey: (id)aKey;
/** Sets object for key, given in aKey as anObject */
- (void) setObject: (id)anObject forKey: (id)aKey;
/** Removes from dictionary pair (aKey; anObject) */
- (void) removeObjectForKey: (id)aKey;
/** Clears dictionary */
- (void) removeAllObjects;

/** Returns number of objects */
- (NSUInteger) count;
/** Initializes this dictionary with data, given in arrays keys[] and objects[] */
- (id) initWithObjects: (id*)objects
	       forKeys: (id*)keys
		 count: (unsigned)count;
/** Returns key enumertor */
- (NSEnumerator*) keyEnumerator;
/** Returns object enumertor */
- (NSEnumerator*) objectEnumerator;

/** Returns copy of this dictionary */
- (id) mutableCopy;
/** Returns immutable MPDictionary copy of this dictionary */
- (id) copy;

/** Initializes this as an empty dictionary */
- init;

/** Initializes this dictionary as empty dictionary and allocates enough memory to place numItems inside */
- (id) initWithCapacity: (unsigned)numItems;
/** Deallocates reciever */
- (void) dealloc;

@end

