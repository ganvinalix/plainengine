#import <MPCore.h>
#import <MPMessageCounterSubject.h>

@interface MPMessageCounter: NSObject
{
@public
	NSUInteger value;
}
-init;
-(void) inc;
-(NSUInteger) value;
@end

@implementation MPMessageCounter

-init
{
	value = 0;
	return [super init];
}

-(void) inc
{
	++value;
}

-(NSUInteger) value
{
	return value;
}

@end


@implementation MPMessageCounterSubject

- initWithString: (NSString *)aParams
{
	[super init];
	counters = [NSMutableDictionary new];
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
	[counters release];
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
	NSEnumerator *enumer = [counters keyEnumerator];
	NSString *msg = nil;
	while ((msg = [enumer nextObject]) != nil)
	{
		[[api log] add: notice withFormat: @"MPMessageCounterSubject: Message \"%@\" had been posted %u times;",
												msg, [[counters objectForKey: msg] value]];
	}
}

- (void) update
{

}

MP_HANDLER_OF_ANY_MESSAGE
{
	MPMessageCounter *c = [counters objectForKey: MP_MESSAGE_NAME];
	if (!c)
	{
		c = [MPMessageCounter new];
		[counters setObject: c forKey: MP_MESSAGE_NAME];
		[c release];
	}
	[c inc];
}

@end


