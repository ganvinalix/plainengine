#import <Foundation/Foundation.h>

@interface MPSpinLock: NSObject <NSLocking>
{
	id lockDelegate;
	NSUInteger maxLoopsCount;
	BOOL locked;
}

-initWithLockClass: (Class)theClass withMaxLoopsCount: (NSUInteger)theMaxLoopsCount;
-initWithLockClass: (Class)theClass;
-initWithLock: (id)theLock withMaxLoopsCount: (NSUInteger)theMaxLoopsCount; //theLock must be unlocked
-initWithLock: (id)theLock; //theLock must be unlocked
-initWithMaxLoopsCount: (NSUInteger)theMaxLoopsCount; //uses MPLock as default lock class
-init; //uses MPLock as default lock class

-(BOOL) isLocked;

-(void) dealloc;

@end

