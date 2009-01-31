#import <MPCore.h>
#import <MPTimerSubject.h>

@interface MPTimerSubjectTimerData: NSObject
{
@public
	NSTimeInterval period, previousTime, startTime;
	NSMutableArray *messages;
}
-init;
-(void)dealloc;
@end
		
@implementation MPTimerSubjectTimerData

-init
{
	period = 1;
	messages = [[NSMutableArray alloc] init];
	return [super init];
}

-(void)dealloc
{
	[messages release];
	[super dealloc];
}

@end

@implementation MPTimerSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	/*
	NSArray *params = [aParams componentsSeparatedByString: @" "];
	period = 1;
	messageName = @"timerTick";
	if ([params count] >= 1)
	{
		period = [[params objectAtIndex: 0] doubleValue];
		if ([params count] >= 2)
		{
			messageName = [params objectAtIndex: 1];
		}
	}
	period /= 1000;
	*/
	timers = [[NSMutableArray alloc] init];
	NSArray *params = [aParams componentsSeparatedByString: @";"];
	NSEnumerator *enumer = [params objectEnumerator];
	NSString *timersString;
	NSMutableString *timerPeriod, *timerMessages;
	while ((timersString = [enumer nextObject]) != nil )
	{
		timerPeriod = [NSMutableString string];
		timerMessages = [NSMutableString string];
		separateString(timersString, timerPeriod, timerMessages, @" ");
		stringTrimLeft(timerMessages);
		
		MPTimerSubjectTimerData *data = [MPTimerSubjectTimerData new];
		data->period = [timerPeriod doubleValue]/1000;
		NSArray *msgs;
		msgs = [timerMessages componentsSeparatedByString: @" "];
		NSUInteger i, count = [msgs count];
		for (i=0; i<count; ++i)
		{
			[data->messages addObject: [msgs objectAtIndex: i]];
		}
		
		[timers addObject: data];
		[data release];
	}
	dictionaryPool = [[MPPool alloc] initWithClass: [MPMutableDictionary class]];
	strPool = [[MPPool alloc] initWithClass: [NSMutableString class]];
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
	[dictionaryPool release];
	[strPool release];
	[timers release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{
	double curTime = [[NSDate date] timeIntervalSince1970];
	NSUInteger i, count = [timers count];
	MPTimerSubjectTimerData *data;
	for (i=0; i<count; ++i)
	{
		data = [timers objectAtIndex: i];
		data->startTime = data->previousTime = curTime;
	}
	paused = NO;
}

- (void) stop
{

}

- (void) update
{
	if (paused)
	{
		return;
	}
	NSUInteger i, count = [timers count];
	MPTimerSubjectTimerData *data;
	for (i=0; i<count; ++i)
	{
		data = [timers objectAtIndex: i];
		NSTimeInterval current, delta;
		current = [[NSDate date] timeIntervalSince1970];
		delta = current - data->previousTime;
		while (delta >= data->period)
		{
			data->previousTime += data->period;
			current = [[NSDate date] timeIntervalSince1970];
			delta = current - data->previousTime;

			NSUInteger j, mcount = [data->messages count];
			for (j=0; j<mcount; ++j)
			{
				id dict = [dictionaryPool newObject];
				NSMutableString *str = [strPool newObject];
				[str setString: @""];
				[str appendFormat: @"%f", data->previousTime - data->startTime];
				[dict setObject: str forKey: @"relativeTime"];
				[api postMessageWithName: [data->messages objectAtIndex: j] userInfo: dict];
				[dict release];
				[str release];
			}
		}
	}
}

MP_HANDLER_OF_MESSAGE(retardTimer)
{
	paused = YES;
}

MP_HANDLER_OF_MESSAGE(resumeTimer)
{
	paused = NO;
}

@end


