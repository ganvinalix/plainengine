#import <MPUtility.h>
#import <config.h>

/* Too cripled implementation. TODO */

@implementation MPPointerWrapper

-init
{
	return [self initWithPointer: NULL];
}

-initWithPointer: (void *)aPointer
{
	[super init];
	pointer = aPointer;
	hash = (NSUInteger)aPointer;
	return self;
}

-(void *) pointer
{
	return pointer;
}

-(NSUInteger) hash
{
	return hash;
}

-(BOOL) isEqual: (id)anObject
{
	if (![anObject isKindOfClass: [self class]])
	{
		return NO;
	}
	return pointer == [anObject pointer];
}

-(id) copyWithZone: (NSZone *)zone
{
	return [[MPPointerWrapper allocWithZone: zone] initWithPointer: pointer];
}

-(NSString *) description
{
	return [NSString stringWithFormat: @"%p", pointer];
}

@end

/* ----------------Conversion functions----------------- */

NSString *pointerToString(void *pointer)
{
	return [NSString stringWithFormat: @"%ld", pointer];
}

NSString *unsignedToString(NSUInteger uns)
{
	return [NSString stringWithFormat: @"%lu", uns];
}

NSUInteger stringToUnsigned(NSString *string)
{
	return (NSUInteger)[string integerValue];
}

void *stringToPointer(NSString *string)
{
	return (void *)[string intValue];
}

/* -------------Functions to work with strings---------- */

void separateString(NSString *source, NSMutableString *left, NSMutableString *right, NSString *separator)
{
	NSArray *comps = [source componentsSeparatedByString: separator];
	NSUInteger i, count = [comps count];
	[right setString: @""];
	[left setString: @""];
	if (!count)
	{
		return;
	}
	[left setString: [comps objectAtIndex: 0]];
	for (i=1; i<count; ++i)
	{
		if (i-1)
		{
			[right appendFormat: @"%@%@", separator, [comps objectAtIndex: i]];
		}
		else
		{
			[right appendString: [comps objectAtIndex: i]];
		}
	}
}

BOOL substringEqual(NSString *str, NSUInteger st, NSUInteger fin, NSString *target)
{
	NSUInteger i;
	for (i=st; i<=fin; ++i)
	{
		if ([str characterAtIndex: i] != [target characterAtIndex: i-st])
		{
			return NO;
		}
	}
	return YES;
}

void replaceSubstr(NSMutableString *str, NSUInteger st, NSUInteger fin, NSString *replacement)
{
	NSString *left, *right;
	left = [str substringToIndex: st];
	right = [str substringFromIndex: fin+1];
	[str setString: @""];
	[str appendFormat: @"%@%@%@", left, replacement, right];
}

BOOL stringContainsSubstring(NSString *str, NSString *substr)
{
	int block = [substr length]-1;
	long i, max=[str length]-[substr length];
	for (i=0; i<=max; ++i)
	{
		if (substringEqual(str, i, i+block, substr))
		{
			return YES;
		}
	}
	return NO;
}

NSUInteger substringCount(NSString *str, NSString *substr)
{
	NSUInteger cnt=0;
	int block = [substr length]-1;
	long i, max=[str length]-[substr length];
	for (i=0; i<=max; ++i)
	{
		if (substringEqual(str, i, i+block, substr))
		{
			++cnt;
		}
	}
	return cnt;
}

void stringReplace(NSMutableString *str, NSString *target, NSString *replacement)
{
	int repLen = [replacement length];
	int block = [target length]-1;
	long i, max=[str length]-[target length];
	for (i=0; i<=max; ++i)
	{
		if (substringEqual(str, i, i+block, target))
		{
			replaceSubstr(str, i, i+block, replacement);
			i += repLen-1;
			max += (repLen - [target length]);
		}
	}
}

void stringTrimLeft(NSMutableString *str)
{
	NSUInteger start=0, i, len = [str length];
	for (i=0; i<len; ++i)
	{
		if ([str characterAtIndex: i] != ' ')
		{
			start = i;
			break;
		}
	}
	[str setString: [str substringFromIndex: start]];
}

void stringTrimRight(NSMutableString *str)
{
	NSUInteger i, len = [str length], fin = len;
	for (i=len-1; i>=0; --i)
	{
		if ([str characterAtIndex: i] != ' ')
		{
			fin = i+1;
			break;
		}
	}
	[str setString: [str substringToIndex: fin]];
}

NSDictionary *parseParamsString(NSString *params)
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSArray *paramsComponents = [params componentsSeparatedByString: @" "];
	NSUInteger i, count = [paramsComponents count];
	for (i=0; i<count; ++i)
	{
		NSMutableString *paramName, *paramValue;
		paramName = [NSMutableString string];
		paramValue = [NSMutableString string];
		separateString([paramsComponents objectAtIndex: i], paramName, paramValue, @":");
		[dict setObject: paramValue forKey: paramName];
	}
	return dict;
}

/* -------------getSelectorAndMethodSignature----------- */

#ifdef GNU_RUNTIME

NSLock *getSelectorAndMethodSignatureLock = nil;

#define GSAMS_LOCK\
	if (!getSelectorAndMethodSignatureLock)\
	{\
		getSelectorAndMethodSignatureLock = [NSLock new];\
	}\
	[getSelectorAndMethodSignatureLock lock]

#define GSAMS_UNLOCK\
	[getSelectorAndMethodSignatureLock unlock]


void getSelectorAndMethodSignature(id object, const char *methodName, SEL *selector, NSMethodSignature **methodSignature)
{
	static NSUInteger typesStringLength=0;
	static char *typesString = NULL;

	SEL methodSelector = sel_registerName(methodName);
	NSMethodSignature *sig = [object methodSignatureForSelector: methodSelector];
	if (sig && !GSTypesFromSelector(methodSelector))
	{
		NSUInteger j, newSize;
		newSize = strlen([sig methodReturnType]) + 1;
		for (j=0; j<[sig numberOfArguments]; ++j)
		{
			newSize += strlen([sig getArgumentTypeAtIndex: j]);
		}
		GSAMS_LOCK;
		if (typesStringLength < newSize)
		{
			typesStringLength = newSize;
			typesString = realloc(typesString, typesStringLength);
			typesString[typesStringLength-1] = '\0';
		}
		typesString[0] = '\0';
		strcat(typesString, [sig methodReturnType]);
		for (j=0; j<[sig numberOfArguments]; ++j)
		{
			strcat(typesString, [sig getArgumentTypeAtIndex: j]);
		}
		methodSelector = GSSelectorFromNameAndTypes(methodName, typesString);
		GSAMS_UNLOCK;
	}
	if (selector)
	{
		*selector = methodSelector;
	}
	if (methodSignature)
	{
		*methodSignature = sig;
	}
}

#else

void getSelectorAndMethodsignature(id object, const char *methodName, SEL *selector, NSMethodSignature **methodSignature)
{
	SEL methodSelector = sel_registerName(methodName);
	NSMethodSignature *sig = [object methodSignatureForSelector: methodSelector];

	if (selector)
	{
		*selector = methodSelector;
	}
	if (methodSignature)
	{
		*methodSignature = sig;
	}
}

#endif

/* ------------------Time functions--------------------- */
#ifdef WIN32

#import <windows.h>

NSUInteger getMilliseconds()
{
	return GetTickCount();
}

float getHighPrecisionMilliseconds()
{
	return GetTickCount();
}

#else

#import <sys/time.h>

NSUInteger getMilliseconds()
{
	struct timeval now;
	gettimeofday(&now, NULL);
	return now.tv_usec/1000 + now.tv_sec*1000;
}

float getHighPrecisionMilliseconds()
{
	struct timeval now;
	gettimeofday(&now, NULL);
	return now.tv_usec/1000.0 + now.tv_sec*1000;
}

#endif

