#import <MPModule.h>
#import <dlfcn.h>
#import <common.h>

@implementation MPModule
- init
{
	[super init];

	_lib_name = [[NSString alloc] initWithString: @"No library loaded"];
	_lib_handle = nil;

	return self;
}
- (void) dealloc
{
	[self unloadLibrary];
	[_lib_name release];

	[super dealloc];
}

- (NSString *) name
{
	return [[_lib_name copy] autorelease];
}

- (BOOL) loadLibraryWithName: (NSString *)aName
{
	if(_lib_handle) return NO;

	_lib_handle = dlopen([aName UTF8String], RTLD_LAZY);
	if (!_lib_handle) 
	{
		[gLog add: error withFormat: @"MPModule: Unable to open library [%s]: %s\n", [aName UTF8String],  dlerror()];
		return NO;
	}

	_lib_name = [aName copy];
	[gLog add: notice withFormat: @"MPModule: Library [%s] has been loaded", [aName UTF8String]];

	return YES;
}
- (BOOL) unloadLibrary
{
	if(!_lib_handle) return NO;

	if(dlclose(_lib_handle) != 0)
	{
		[gLog add: error withFormat: @"MPModule: Unable to close library [%s]: %s\n", [_lib_name UTF8String],  dlerror()];
		return NO;
	}

	[gLog add: notice withFormat: @"MPModule: Library [%s] has been unloaded", [_lib_name UTF8String]];

	_lib_handle = nil;
	[_lib_name release];
	_lib_name = [[NSString alloc] initWithString: @"No library loaded"];

	return YES;
}

- (void *) getSymbol: (NSString *)aSymbolName
{
	if(!_lib_handle) [gLog add: error withFormat: @"MPModule: No library loaded"];
	void *sym = dlsym(_lib_handle, [aSymbolName UTF8String]);
	if(!sym) [gLog add: warning withFormat: @"MPModule: Unable to find symbol [%s] in [%s] module", [aSymbolName UTF8String], [_lib_name UTF8String]];

	return sym;
}

+ module
{
	return [[MPModule new] autorelease];
}
@end

