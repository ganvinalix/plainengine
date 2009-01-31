#import <MPCore.h>

/**
  This subject is used for running primitive scripts as console commands;
  For help print 'helpbatch' in console;
  */
@interface MPConsoleBatchSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	BOOL initializeBatch;
	NSString *initializer;
}
-(void) executeBatch: (NSString *)runstring;
MP_HANDLER_OF_MESSAGE(consoleInput);
@end

