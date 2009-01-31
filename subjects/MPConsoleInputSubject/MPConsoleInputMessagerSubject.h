#import <MPCore.h>

/**
  This subject is addition to MPConsoleInputSubject.
  It catches 'consoleInput' notification, parses its 'message' param and posts notification.
  Syntax for console command: 'm notification_name/param1=param1value/param2=param2value/...'
  Examples:
  1) 'm notif' - posts notification 'notif' with no params;
  2) 'm notif/p1=v1' - posts notification 'notif' with param 'p1', its value is 'v1'
  3) 'm notif/p1=a=b=c' - posts notification 'notif' with param 'p1', its value is 'a=b=c'
  4) 'm notif/p1=v1/p2=v2' - posts notificatin 'notif' with params 'p1' and 'p2'; their values are 'v1' and 'v2'
  Also there is 'r' command for requests with same syntax;
  */
@interface MPConsoleInputMessagerSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
}
MP_HANDLER_OF_MESSAGE(consoleInput);
@end


