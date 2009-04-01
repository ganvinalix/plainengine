#import <MPThreadStrategy.h>

@interface MPForkedThreadStrategy : MPThreadStrategy
{
@private
	// synchronization objects
	NSLock 	*stateMutex;
	NSLock 	*accessMutex;
	// state flags
	BOOL 	working;
	BOOL 	done;
	BOOL 	paused;
	BOOL	prepared;
	BOOL updating;
	// Selector and MPThread
	SEL 	selector;
	id 	thread;
}
- (void)proxyRoutine;
@end

