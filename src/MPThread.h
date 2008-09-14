#import <Foundation/Foundation.h>
#import <MPNotificationQueue.h>
#import <MPSubject.h>

@interface MPThread : NSObject
{
@private
	NSLock *accessMutex;
	MPNotificationQueue *notifications;
	BOOL inWork;
	BOOL mustWork;
	NSMutableDictionary *subjects; // name to subject
	NSMutableDictionary *selector_timers; // message's name to timer with selector
	NSMutableDictionary *feature_adders; // feature name to NSArray of selectors, which must be executed when this feature with that name was added
}
- init;
- (void) dealloc;
+ thread;
//
- (BOOL) isWorking;
- (void) start;
- (void) stop;
- (void) pause;
- (void) resume;
// 
- (void) threadRoutine;
//
- (BOOL) addSubject: (id<MPSubject>)aSubject withName: (NSString *)aName;
- (BOOL) removeSubjectWithName: (NSString *)aName;
@end
