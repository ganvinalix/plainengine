#import <MPAPI.h>
#import <core_constants.h>
#import <MPNotifications.h>
#import <MPObject.h>

@implementation MPAPI

+api
{
	return [[[[self class] alloc] init] autorelease];
}

- init
{
	[super init];

	_thread = nil;
	emptyDictionaryPool = [[MPPool alloc] initWithClass: [MPDictionary class]];

	return self;
}

- (void) dealloc
{
	[self setCurrentThread: nil];
	[super dealloc];
}

-(void) yield
{
	//[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: anInterval]];
	if(_thread)
	{
		[_thread yield];
	}
	else
	{
		[gLog add: warning withFormat: @"There is no current thread into MPAPI instance."];
	}
	//edited by ChaoX (I had almost broken my eyes when read that)
}

-(void) postMessageWithName: (NSString *)aName
{
	[self postMessageWithName: aName userInfo: nil];
}

-(void) postMessageWithName: (NSString *)aName userInfo: (MPCDictionaryRepresentable *) anUserInfo
{
	MP_ASSERT(aName, @"Message name must not be nil");

	BOOL wasNil = NO;
	if(anUserInfo == nil) 
	{
		anUserInfo = [MPDictionary new];
		wasNil = YES;
	}

	MPPostNotification(aName, anUserInfo);

	if(wasNil) [anUserInfo release];
}

-(id<MPVariant>) postRequestWithName: (NSString *)aName
{
	return [self postRequestWithName: aName userInfo: nil];
}

-(id<MPVariant>) postRequestWithName: (NSString *)aName userInfo: (MPCDictionaryRepresentable *)anUserInfo
{
	MP_ASSERT(aName, @"Message name must not be nil");

	BOOL wasNil = NO;
	if(anUserInfo == nil) 
	{
		anUserInfo = [MPDictionary new];
		wasNil = YES;
	}

	MPResultCradle *response = [MPResultCradle new];
	MPVariant *result = nil;
	MPPostRequest(aName, anUserInfo, response);

	// remember current time
	NSDate *startTime = [NSDate date];
	// waiting for response 
	NSUInteger i = 0;
	NSTimeInterval maxTime = - (MPTHREAD_MAX_WAIT_FOR_REQUEST_TIME)/1000;
	while( [response getResult] == nil )
	{
		if( [startTime timeIntervalSinceNow] < maxTime )
		{
			if(i >= 5)
			{
				[gLog add: warning withFormat: @"Waiting for response to '%@' request. TIME IS OVER!", aName];
				break;
			}

			[gLog add: warning withFormat: @"Waiting too long for response to '%@' request", aName];
			startTime = [NSDate date];

			++i;
		}
		[self yield];
	}

	result = [response getResult];
	// if abnormal exititng
	if(result == nil) result = [MPVariant variantWithString: @""];

	[response release];

	if(wasNil) [anUserInfo release];

	return result;
}

-(Class<MPObject>) getObjectSystem
{
	return [MPObject class];
}

- (void) setCurrentThread: (MPThread *)aThread
{
	if(_thread) [_thread release];
	if(aThread) _thread = [aThread retain];
}

- (id<MPLog>) log
{
	return gLog;
}

@end
