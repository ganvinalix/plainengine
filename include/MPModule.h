#import <Foundation/Foundation.h>

@interface MPModule : NSObject
{
	void *_lib_handle;
	NSString *_lib_name;
}
- (BOOL) loadLibraryWithName: (NSString *)aName;
- (BOOL) unloadLibrary;

- (NSString *) name;

- (void *) getSymbol: (NSString *)aSymbolName;

+ module;
@end

