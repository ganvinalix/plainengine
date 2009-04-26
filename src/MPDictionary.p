#import <Foundation/Foundation.h>

typedef void * MPCDictionary;

/** Protocol which means that object can be represented as pure-C dictionary (see dictionary.h for details) */
@protocol MPCDictionaryRepresentable

/** Returns pointer to pure-C dictionary, equal to this dictionary. You must not free it when you finish! */
- (MPCDictionary) getCDictionary;

/** Initializes this dictionary with copy of content stored in newDict */
- initWithCDictionary: (MPCDictionary)newDict;

@end

/** Typedef for all dictionaries that conforms to MPCDictionaryRepresentable protocol (MPDictionary, MPMutableDictionary) */
typedef NSDictionary <MPCDictionaryRepresentable> MPCDictionaryRepresentable;

