#import <MPUtility.h>

/* Too cripled implementation. TODO */

NSString *pointerToString(void *pointer)
{
	return [NSString stringWithFormat: @"%ld", pointer];
}

NSString *unsignedToString(NSUInteger uns)
{
	return [NSString stringWithFormat: @"%u", uns];
}

NSUInteger stringToUnsigned(NSString *string)
{
	return (NSUInteger)[string intValue];
}

void *stringToPointer(NSString *string)
{
	return (void *)[string intValue];
}

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
			i += repLen;
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

