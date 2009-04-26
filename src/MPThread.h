#import <Foundation/Foundation.h>
#import <MPNotificationQueue.h>
#import <MPSubject.p>
#import <MPThreadStrategy.h>
#import <MPUtility.h>

typedef enum
{
	message_receiving = 0,
	request_receiving, 
	elements_count
} subject_binding_target;


@interface MPThread : NSObject
{
@private
	unsigned threadID;
	// stuff
	MPNotificationQueue *notifications;
	MPThreadStrategy *strategy;
	NSMutableArray *routinesStack;
	// profilng
	MPCodeTimer *threadTimer;
	// containers
	NSMutableArray *subjects; // name to subject
	NSMutableDictionary *messageNameToSubscribedSubjects; // message name to array of subscribed subjects
	NSMutableDictionary *requestNameToSubscribedSubjects; // request name to array of subscribed subjects
	NSMutableArray *subjectsWhichHandleAllMessages;
	SEL selFor_MPHandlerOfAnyMessage;
}
- init;
- initWithStrategy: (MPThreadStrategy *)aStrategy withID: (unsigned)thId;
- (void) dealloc;
+ thread;
+ threadWithStrategy: (MPThreadStrategy *)aStrategy withID: (unsigned)thId;
//
- (BOOL) isWorking;
- (BOOL) isPaused;
- (BOOL) isPrepared;
- (BOOL) isUpdating;

- (void) prepare;
- (void) start;
- (void) stop;
- (void) pause;
- (void) resume;
// 
- (void) threadRoutine;
- (BOOL) processNextMessage;
- (void) yield;

//
- (BOOL) addSubject: (id<MPSubject>)aSubject; 
- (BOOL) removeSubject: (id<MPSubject>)aSubject;

// Subjects (un)binding functons
// binds subject to messages it responds to
- (void) bindMethodsOfSubject: (id<MPSubject>)aSubject;
// binds subject (aSubject) to message with a specified type (aTarget) and a name (aName)
- (BOOL) bindSubject: (id<MPSubject>)aSubject to: (subject_binding_target)aTarget withName: (NSString *)aName;
// unbinds subject from all messages it binded to
- (void) unbindSubject: (id<MPSubject>)aSubject;

// returns thread description as a string
- (NSString*) description;
// returns thread id which is specified in engine configuration file
- (unsigned) getID;
@end

