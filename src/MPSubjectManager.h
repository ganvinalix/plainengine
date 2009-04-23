#import <Foundation/Foundation.h>
#import <common.h>
#import <MPSubject.p>
#import <MPThread.h>

/** Subject manager class */
@interface MPSubjectManager : NSObject
{
	NSMutableDictionary *threads;
	NSMutableDictionary *subjectToThread;
	NSMutableDictionary *nameToSubject;
	BOOL paused;
	BOOL isWorking;
	NSLock *accessMutex;
}

/** Returns default subject manager */
+ (id) subjectManager;

/** Initializes subject manager */
- init;
/** Deallocates reciever */
- (void) dealloc;

/** Adds new subject to given thread; if subject with such name exists, returns NO */
- (BOOL) addSubject: (id<MPSubject>)subject toThread: (unsigned)thread withName: (NSString*)name;
/** Removes subject with given name; if doesn't exists, returns NO */
- (BOOL) removeSubjectWithName: (NSString*)name;
/** Pauses subjects */
- (void) pause;
/** Resumes subjects */
- (void) resume;
/** Starts main loop */
- (void) run;
/** Stops all subjects and finishes program */
- (void) terminate;
/** Removes all subjects from subject manager */
- (void) removeSubjects;

@end

