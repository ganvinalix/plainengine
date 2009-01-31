#import <MPCore.h>
#import <MPDestructionSubject.h>

@protocol MPDestructionSubjectDestructableObjectDummy
-(BOOL) canBeDestructedBy: (NSString *)destructorName;
@end

@implementation MPDestructionSubject

- initWithString: (NSString *)aParams
{
	[super init];
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

- (void) update
{
}

BOOL canBeDestructedBy(id object, id destructor)
{
	if ([destructor hasFeature: @"destructor"] && [object hasFeature: @"destructable"])
	{
		if ([object respondsToSelector: @selector(canBeDestructedBy:)])
		{
			return [object canBeDestructedBy: [destructor getName]];
		}
		else
		{
			return YES;
		}
	}
	else
	{
		return NO;
	}
}

MP_HANDLER_OF_MESSAGE(objectsCollided)
{
	id obj1, obj2;
	obj1 = [[api getObjectSystem] getObjectByName: [MP_MESSAGE_DATA objectForKey: @"object1Name"]];
	obj2 = [[api getObjectSystem] getObjectByName: [MP_MESSAGE_DATA objectForKey: @"object2Name"]];
	BOOL destruct1, destruct2;
	destruct1 = canBeDestructedBy(obj1, obj2);
	destruct2 = canBeDestructedBy(obj2, obj1);
	if (destruct1)
	{
		[obj1 clean];
		//[[api log] add: notice withFormat: @"%@ destroyed", obj1];
	}
	if (destruct2)
	{
		[obj2 clean];
		//[[api log] add: notice withFormat: @"%@ destroyed", obj2];
	}
}

@end


