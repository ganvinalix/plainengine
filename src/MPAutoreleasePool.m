#import <MPAutoreleasePool.h>
#import <common.h>

objectList *listalloc()
{
	objectList *list = malloc(sizeof(objectList));
	list->obj = nil;
	list->next = NULL;
	return list;
}

@implementation MPAutoreleasePool

+allocWithZone: (NSZone *)zone
{
	/** Tambourine to avoid loading NSAutoreleasePool from cache */
	return NSAllocateObject(self, 0, zone);
}

+new
{
	return [[MPAutoreleasePool alloc] init];
}

-init
{
	[super init];
	head = listalloc();
	tail = head;
	size=0;

	return self;
}

-(void) addObject: (id)object
{
	NSAssert(tail, @"Adding object to deallocated MPAutoreleasePool");
	++size;
	tail->obj = object;
	if (!tail->next)
	{
		tail->next = listalloc();
	}
	tail = tail->next;
}

-(NSUInteger) size
{
	return size;
}

-(void) clean
{
	size=0;
	objectList *list=head;
	while (list != tail)
	{
		#ifdef MPAUTORELEASEPOOL_LOGGING
		[gLog add: info withFormat: @"MPAutoreleasePool: releasing [%@] - \"%@\"", 
										[list->obj class], list->obj];
		#endif
		[list->obj release];
		list->obj = nil;
		list=list->next;
	}
	tail=head;
	#ifdef MPAUTORELEASEPOOL_LOGGING
	[gLog add: info withFormat: @"MPAutoreleasePool: cleaning complete."];
	#endif
}

-(void) logObjects
{
	objectList *list = head;
	while (list)
	{
		if (list->obj)
		{
			[gLog add: info withFormat: @"MPAutoreleasePool: [%@] - \"%@\"", 
										[list->obj class], list->obj];
		}
		list = list->next;
	}
}

-(void) dealloc
{
	[self clean];
	while (head)
	{
		objectList *old;
		old = head;
		head = head->next;
		free(old);
	}
	head=tail=NULL;
	[super dealloc];
}

@end

