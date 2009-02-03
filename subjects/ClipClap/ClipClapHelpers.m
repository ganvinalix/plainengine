#import <ClipClapHelpers.h>

void setupObject(id<MPAPI> api, id<MPObject> object, NSString *type)
{
	id dict = [MPMutableDictionary new];
	[dict setObject: @"e" forKey: @"commandname"];
	[dict setObject: [NSString stringWithFormat: @"obj_setup_%@.mpb %@", type, [object getName]] forKey: @"commandparams"];
	[api postMessageWithName: @"consoleInput" userInfo: dict];
	[dict release];
}

