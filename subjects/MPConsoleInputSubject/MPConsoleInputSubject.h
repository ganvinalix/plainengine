#import <MPCore.h>

#define MPCIS_BUFLEN 1024 

/**
  This subject catchess console input and posts notification 'consoleInput' with params:
	-commandname: first word of input string;
	-commandparams: all but first words of input string
  NOTE: If input string length is more than 255, every 255 symbols would be parsed as different commands.
  */
@interface MPConsoleInputSubject : NSObject <MPSubject>
{
	char buf[MPCIS_BUFLEN+1];
	id <MPAPI> api;
	MPPool *dictpool, *strpool;
}
@end


