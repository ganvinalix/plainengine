#import <Foundation/Foundation.h>
#import <common.h>
#import <MPSubjectManager.h>

@interface MPSubjectDescription : NSObject
{
	NSString *subjectName, *subjectAlias, *moduleName, *params;
	NSUInteger threadId;
}
- init;
- initWithSubjectName: (NSString *)sName
		   subjectAlias: (NSString *)sAlias
		   moduleName: (NSString *)mName
			 threadId: (NSUInteger)tId
	 parametersString: (NSString *)par;

- (void) setSubjectName: (NSString *)sName
		   subjectAlias: (NSString *)sAlias
			 moduleName: (NSString *)mName
			   threadId: (NSUInteger)tId
	   parametersString: (NSString *)par;

- (NSString *) getSubjectName;
- (NSString *) getSubjectAlias;
- (NSString *) getModuleName;
- (NSString *) getParametersString;
- (NSUInteger) getThreadId;
@end

NSArray *MPParseLinkerConfig(NSString *config);
id MPLinkModules(NSArray *descriptions, MPSubjectManager *subjMan);
void MPUnloadModules(id linkerState);

