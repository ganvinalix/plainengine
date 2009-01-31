#import <MPCore.h>

/**
  This subject is used for manipulating object system via the consoleInput message;
  Print 'helpobj' for help;
 */
@interface MPConsoleInputObjectManipulatorSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	MPMapper *handler;
	NSMutableArray *objectsArray;
}
MP_HANDLER_OF_MESSAGE(consoleInput);
@end


