#import <MPSynchronizedQueue.h>

@implementation MPSynchronizedQueue

-init
{
	[super init];
	queue = [NSMutableArray new];
	mutex = [MPSpinLock new];
	return self;
}

-(void) dealloc
{
	[mutex lock];
	[queue release];
	[mutex unlock];
	[mutex release];
	[super dealloc];
}

-(void) push: (id)elem
{
	[mutex lock];
	[queue addObject: elem];
	[mutex unlock];
}

-(id) pop
{
	id elem = nil;
	[mutex lock];
	if ([queue count] != 0)
	{
		elem = [[[queue objectAtIndex: 0] retain] autorelease];
		[queue removeObjectAtIndex: 0];
	}
	[mutex unlock];
	return elem;
}

@end

