#import <MPStringToCStringConverter.h>


@implementation MPStringToCStringConverter

-init
{
	return [self initWithCapacity: 1];
}

-initWithCapacity: (NSUInteger)capacity
{
	if (!capacity)
	{
		capacity = 1;
	}
	buflen = capacity;
	buffer = malloc(buflen);
	buffer[0] = '\0';
	return [super init];
}

-(char const *) stringToCStr: (NSString *)str
{
	NSUInteger len = [str maximumLengthOfBytesUsingEncoding: NSUTF8StringEncoding];
	if (len+1 > buflen)
	{
		buffer = realloc(buffer, (len+1)*sizeof(char));
		buflen = len+1;
	}
	[str getCString: buffer maxLength: buflen encoding: NSUTF8StringEncoding];
	return buffer;
}

-(void) dealloc
{
	free(buffer);
	[super dealloc];
}

@end

