#import <MPSpinLock.h>
#import <config.h>

@implementation MPSpinLock

-initWithLock: (id)theLock withMaxLoopsCount: (NSUInteger)theMaxLoopsCount
{
	[super init];
	lockDelegate = [theLock retain];
	maxLoopsCount = theMaxLoopsCount;
	locked = NO;
	return self;
}

-initWithLock: (id)theLock
{
	return [self initWithLock: theLock withMaxLoopsCount: MPSPINLOCK_DEFAULT_MAX_LOOPS_COUNT];
}

-initWithLockClass: (Class)theClass withMaxLoopsCount: (NSUInteger)theMaxLoopsCount
{
	return [self initWithLock: [[[theClass alloc] init] autorelease] withMaxLoopsCount: theMaxLoopsCount];
}

-initWithLockClass: (Class)theClass
{
	return [self initWithLockClass: theClass withMaxLoopsCount: MPSPINLOCK_DEFAULT_MAX_LOOPS_COUNT];
}

-initWithMaxLoopsCount: (NSUInteger)theMaxLoopsCount; //uses MPLock as default lock class
{
	return [self initWithLockClass: [NSLock class] withMaxLoopsCount: theMaxLoopsCount];
}

-init
{
	return [self initWithLockClass: [NSLock class]];
}

-(void) dealloc
{
	[lockDelegate release];
	[super dealloc];
}

-(void) lock
{
	NSUInteger lockCounter = 0;
	BOOL success = NO;
	do
	{
		success = [lockDelegate tryLock];
		++lockCounter;
	}
	while (!success && (lockCounter < maxLoopsCount));
	if (!success)
	{
		[lockDelegate lock];
	}
	locked = YES;
}

-(void) unlock
{
	[lockDelegate unlock];
	locked = NO;
}

-(BOOL) isLocked
{
	return locked;
}

@end

