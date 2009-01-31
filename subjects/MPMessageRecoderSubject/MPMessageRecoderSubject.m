#import <MPCore.h>
#import <MPMessageRecoderSubject.h>

@implementation MPMessageRecoderSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	recodingsDictionary = [[NSDictionary alloc] initWithContentsOfFile: aParams];
	return self;
}

- init
{
	return [self initWithString: @""];
}

- (void) dealloc
{
	if (api)
	{
		[api release];
	}
	[recodingsDictionary release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{

}

- (void) stop
{

}

- (void) update
{

}

void replaceByDictionary(NSMutableString *str, NSDictionary *dict)
{
	NSEnumerator *enumer = [dict keyEnumerator];
	NSString *key;
	while ((key = [enumer nextObject]) != nil)
	{
		stringReplace(str, [NSString stringWithFormat: @"$%@", key], [dict objectForKey: key]);
	}
}

MP_HANDLER_OF_ANY_MESSAGE
{
	NSString *recoded;
	if ((recoded = [recodingsDictionary objectForKey: MP_MESSAGE_NAME]) != nil)
	{
		NSMutableString *name = [NSMutableString string], *params = [NSMutableString string];
		separateString(recoded, name, params, @" ");
		replaceByDictionary(name, MP_MESSAGE_DATA);
		NSArray *paramsArr = [params componentsSeparatedByString: @"/"];
		id msgdict = [MPMutableDictionary new];
		NSUInteger i, count = [paramsArr count];
		for (i=0; i<count; ++i)
		{
			NSMutableString *finalKey = [NSMutableString string],
						  *finalValue = [NSMutableString string];

			separateString([paramsArr objectAtIndex: i], finalKey, finalValue, @"=");
			replaceByDictionary(finalKey, MP_MESSAGE_DATA);
			replaceByDictionary(finalValue, MP_MESSAGE_DATA);
			[msgdict setObject: finalValue forKey: finalKey];
		}
		[api postMessageWithName: name userInfo: msgdict];
		[msgdict release];
	}
}

@end


