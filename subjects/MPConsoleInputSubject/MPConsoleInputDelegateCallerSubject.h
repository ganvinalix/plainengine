#import <MPCore.h>

/**
  This subject is used to call delegate methods
  Print 'helpdcall' for help;
  */
@interface MPConsoleInputDelegateCallerSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
}
MP_HANDLER_OF_MESSAGE(consoleInput);
@end


