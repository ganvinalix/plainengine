#import <MPCore.h>

/**
  This subject is used for running primitive scripts as console commands;
  For help print 'helpbatch' in console;
  */
@interface MPConsoleInputLoopSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	MPPool *dictionaryPool;
}
MP_HANDLER_OF_MESSAGE(consoleInput);
@end

