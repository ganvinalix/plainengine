#import <Foundation/Foundation.h>
#import <dictionary.h>
#import <MPDictionary.p>

/**
 * Class which repeats functions of NSDictionary except:
 * 1) Permits only NSString as keys and objects; 
 * 2) Has ability to get pointer to dictionary structure with elements of MPDictionary which can be used in pure-C code
 */
@interface MPDictionary : NSDictionary <MPCDictionaryRepresentable>
{
@private
	NSLock *accessLock;
	BOOL dictowning;
	id valconv;
	id kconv;
	MPCDictionary dict;
}

+ newDictionary;

/** Returns number of objects */
- (NSUInteger) count;
/** Returns object for given key */
- (id) objectForKey: (id)aKey;

/** Returns key enumertor */
- (NSEnumerator *) keyEnumerator;
/** Returns object enumertor */
- (NSEnumerator *) objectEnumerator;

/** Returns MPMutableDictionary with data equal to data stored in this dictionary */
- (id) mutableCopy;
/** Returns copy of this dictionary */
- (id) copy;

/** Initializes this dictionary with data, given in arrays keys[] and objects[] */
- (id) initWithObjects: (id *)objects
			   forKeys: (id *)keys
				 count: (unsigned)count;

/** Initializes this dictionary as empty (And never it can be filled with data later) */
- init;

/** Deallocates reciever */
- (void) dealloc;

@end

/**
 * Class which repeats functions of NSMutableDictionary except:
 * 1) Permits only NSString as keys and objects; 
 * 2) Has ability to get pointer to dictionary structure with elements of MPDictionary which can be used in pure-C code
 * WARNING: This class isn't derived from MPDictionary!
 */
@interface MPMutableDictionary : NSMutableDictionary <MPCDictionaryRepresentable>
{
@private
	NSLock *accessLock;
	BOOL dictowning;
	MPCDictionary dict;
	id objconv, valconv;
}

+ newDictionary;

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
- (id) initWithObjects: (id *)objects
		       forKeys: (id *)keys
				 count: (unsigned)count;
/** Returns key enumertor */
- (NSEnumerator *) keyEnumerator;
/** Returns object enumertor */
- (NSEnumerator *) objectEnumerator;

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


