#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C"
{
#endif

#import <MPLog.h>
#import <MPFileLogChannel.h>
#import <MPConfigDictionary.h>
#import <MPCodeTimer.h>
#import <MPDictionary.h>
#import <MPPool.h>
#import <MPMapper.h>
#import <MPModule.h>
#import <MPVariant.h>
#import <MPPair.h>
#import <MPAutoreleasePool.h>
#import <MPStringToCStringConverter.h>
#import <MPRemovalStableList.h>
#import <MPUniversalDelegate.h>
#import <ClassInspection.h>
#import <common_defines.h>

#import <dictionary.h>
#import <release_bunch.h>


/* Utilitary functions for encoding often-used types as strings
   for passing them as message params. No guarantee that strings
   will be human-readable, but they will be decoded correctly
 */
NSString *pointerToString(void *pointer);
NSString *unsignedToString(NSUInteger uns);
NSUInteger stringToUnsigned(NSString *string);
void *stringToPointer(NSString *string);

/** Separates string by first occurance of separator */
void separateString(NSString *source, NSMutableString *left, NSMutableString *right, NSString *separator);

/** Returns YES is substr is found in str */
BOOL stringContainsSubstring(NSString *str, NSString *substr);

/** Returns number of substr occurances in str */
NSUInteger substringCount(NSString *str, NSString *substr);

/** Replaces all occurances of 'target' to 'replacement' in 'str' */
void stringReplace(NSMutableString *str, NSString *target, NSString *replacement);
/** Removes leading spaces */
void stringTrimLeft(NSMutableString *str);
/** Removes spaces at the end of the string */
void stringTrimRight(NSMutableString *str);

/** Parses param string like "a:b cc:d e ..." to dictionary ({a=b; cc=d; e=""; ...} in this example) */
NSDictionary *parseParamsString(NSString *params);

/** Provides an abstraction over Apple or GNU runtime; Params selector and methodSignature may be NULL */
void getSelectorAndMethodSignature(id object, const char *methodName, SEL *selector, NSMethodSignature **methodSignature);

NSUInteger getMilliseconds();
float getHighPrecisionMilliseconds();

#ifdef __cplusplus
}
#endif

