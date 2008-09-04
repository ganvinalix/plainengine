#import <Foundation/Foundation.h>
#import <common.h>
#import <MPSubject.h>
#import <MPThread.h>

/** Subject manager class */
@interface MPSubjectManager : NSObject
{
	NSMutableArray *threads;
	NSMutableDictionary *subjectToThread;
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
- (BOOL) addSubject: (id<MPSubject>)subject toThread: (NSUInteger)thread withName: (NSString*)name;
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

@end

