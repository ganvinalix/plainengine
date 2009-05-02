#import <Foundation/Foundation.h>

/** This class is used for often-used string to CString conversions.
    It contains precached buffer which automatically widens when need.
	NOTE:	When you had converted string, you must use c-string immediately,
			before it would be erased by next conversion.
			If you would need this string after, strcpy it
			Note that in such situation using MPStringToCStringConverter gives no profit.*/
@interface MPStringToCStringConverter : NSObject
{
	char *buffer;
	NSUInteger buflen;
}
-init;
-initWithCapacity: (NSUInteger)capacity;
-(char const *) stringToCStr: (NSString *)str;
-(void) dealloc;
@end


