#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C"
{
#endif

#import <MPLog.h>
#import <MPFileLogChannel.h>
#import <MPConfigFacilities.h>
#import <MPConfigDictionary.h>
#import <MPProfiling.h>
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
#import <MPSpinLock.h>
#import <MPSynchronizedQueue.h>
#import <MPNonblockingQueue.h>
#import <ClassInspection.h>
#import <common_defines.h>

#import <dictionary.h>
#import <release_bunch.h>

/** Class for wrapping pointers to use them as keys in Foundation containers */
@interface MPPointerWrapper: NSObject <NSCopying>
{
	void *pointer;
	NSUInteger hash;
}

-init;
-initWithPointer: (void *)aPointer;

-(void *) pointer;

-(NSUInteger) hash;
-(BOOL) isEqual: (id)anObject;

-(NSString *) description;

@end

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

/** Returns number of milliseconds passed since some moment. It's guaranteed only that this moment would be the same while running. */
NSUInteger getMilliseconds();
/** Returns number of milliseconds passed since some moment. It's guaranteed only that this moment would be the same while running. */
float getHighPrecisionMilliseconds();

/** Checks if msecs was gone since last successful call and if it was, performs statement. (tag should be unique per block) <br>
	Example:<br>
	<code>
		-(void) update
		{
			DO_WITH_MSECS_INTERVAL(1000, t)
				printf("One second passed.\n")
		}
	</code>
 */
#define DO_WITH_MSECS_INTERVAL(msecs, tag)\
		static NSUInteger __prev_time##tag = 0;\
		if (!__prev_time##tag)\
		{\
			__prev_time##tag = getMilliseconds();\
		}\
		NSUInteger __cur_time##tag = getMilliseconds();\
		BOOL __acting##tag = NO;\
		if ((__cur_time##tag - __prev_time##tag) >= msecs)\
		{\
			__prev_time##tag = __cur_time##tag;\
			__acting##tag = YES;\
		}\
		if (__acting##tag)


BOOL MPCompareAndSwapPointer(void * volatile *destination, void *comperand, void *exchange);

#ifdef __cplusplus
}
#endif

