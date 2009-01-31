#import <ClipClapHelpers.h>

void setupObject(id<MPAPI> api, id<MPObject> object, NSString *type)
{
	id dict = [MPMutableDictionary new];
	[dict setObject: @"e" forKey: @"commandname"];
	[dict setObject: [NSString stringWithFormat: @"cc_setup%@.mpb %@", type, [object getName]] forKey: @"commandparams"];
	[api postMessageWithName: @"consoleInput" userInfo: dict];
	[dict release];
}

