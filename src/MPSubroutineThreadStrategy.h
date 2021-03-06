#import <MPThreadStrategy.h>
#import <common.h>

@interface MPSubroutineThreadStrategy : MPThreadStrategy
{
@private
	// state flags
	BOOL working;
	BOOL done;
	BOOL paused;
	BOOL prepared;
	BOOL updating;
	// timer
	NSTimer *_timer;
	// innerPool
	MPAutoreleasePool *innerPool;
	NSUInteger counter;
}
@end

