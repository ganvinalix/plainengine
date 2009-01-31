#import <MPCore.h>
#import <MPConsoleInputLoggerSubject.h>

@implementation MPConsoleInputLoggerSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	return self;
}

- init
{
	return [self initWithString: @""];
}

- (void) dealloc
{
	if (api)
	{
		[api release];
	}
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{

}

- (void) stop
{

}

MP_HANDLER_OF_MESSAGE(consoleInput)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *str = [MP_MESSAGE_DATA objectForKey: @"commandparams"];
	
	if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"log"])
	{
		NSMutableString *level, *message;
		level = [NSMutableString string];
		message = [NSMutableString string];
		NSMutableString *current = level;
		NSUInteger i, count = [str length];
		for (i=0; i<count; ++i)
		{
			if (([str characterAtIndex: i] == ' ') && (current != message))
			{
				current = message;
				continue;
			}
			[current appendFormat: @"%C", [str characterAtIndex: i]];
		}
		mplog_level lev;
		if ([level isEqualToString: @"info"])
		{
			lev = info;
		}
		else if ([level isEqualToString: @"notice"])
		{
			lev = notice;
		}
		else if ([level isEqualToString: @"warning"])
		{
			lev = warning;
		}
		else if ([level isEqualToString: @"error"])
		{
			lev = error;
		}
		else if ([level isEqualToString: @"alert"])
		{
			lev = alert;
		}
		else if ([level isEqualToString: @"critical"])
		{
			lev = critical;
		}
		else
		{
			lev = user;
		}
		[[api log] add: lev withFormat: @"%@", message];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"helplog"])
	{
		[[api log] add: info withFormat: @"log info/notice/warning/error/alert/critical/user <message>\t - logs message"];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"help"])
	{
		[[api log] add: info withFormat: @"helplog - MPConsoleInputLoggerSubject help"];
	}

	[pool release];
}

- (void) update
{

}

@end


