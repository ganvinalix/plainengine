#import <MPCore.h>

/*
	This subject is used to make attracted objects (with feature 'attracted') to become attractors (gain feature 'attractor');
	For correct work, message 'attractorChainTick' must be sent periodically. (500 ms recommended)
 */
@interface MPAttractorChainSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	NSMutableArray *banned;
}
MP_HANDLER_OF_MESSAGE(attractorChainTick);
@end


