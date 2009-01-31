#import <MPCore.h>

/**
  This subject used for logging via the consoleInput
  Print 'helplog' for help;
  */
@interface MPConsoleInputLoggerSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
}
MP_HANDLER_OF_MESSAGE(consoleInput);
@end


