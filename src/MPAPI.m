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
	[emptyDictionaryPool release];
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
		[gLog add: alert withFormat: @"There is no current thread into MPAPI instance."];
	}
}

-(void) postMessageWithName: (NSString *)aName
{
	[self postMessageWithName: aName userInfo: nil];
}

-(void) postMessageWithName: (NSString *)aName userInfo: (MPCDictionaryRepresentable *) anUserInfo
{
	NSAssert(aName, @"Message name must not be nil");

	if(anUserInfo == nil) 
		anUserInfo = [emptyDictionaryPool newObject];
	else
		[anUserInfo retain];

	MPPostNotification(aName, anUserInfo);

	[anUserInfo release];
}

-(id<MPVariant>) postRequestWithName: (NSString *)aName
{
	return [self postRequestWithName: aName userInfo: nil];
}

-(id<MPVariant>) postRequestWithName: (NSString *)aName userInfo: (MPCDictionaryRepresentable *)anUserInfo
{
	NSAssert(aName, @"Message name must not be nil");

	if(anUserInfo == nil) 
		anUserInfo = [emptyDictionaryPool newObject];
	else
		[anUserInfo retain];

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
	if(result == nil) 
		result = [MPVariant variantWithString: @""];

	[response release];

	[anUserInfo release];

	return result;
}

-(Class<MPObject>) getObjectSystem
{
	return [MPObject class];
}

- (void) setCurrentThread: (MPThread *)aThread
{
	[_thread release];
	_thread = [aThread retain];
}

- (id<MPLog>) log
{
	return gLog;
}

@end
