#import <Foundation/Foundation.h>
#import <common.h>
#import <MPSubject.h>
#import <MPThread.h>

@interface MPSubjectManager : NSObject
{
	NSMutableArray *threads;
	NSMutableDictionary *subjectToThread;
	BOOL paused;
	BOOL isWorking;
	NSLock *accessMutex;
}

+ (id) subjectManager;

- init;
- (void) dealloc;

- (BOOL) addSubject: (id<MPSubject>)subject toThread: (NSUInteger)thread withName: (NSString*)name;
- (BOOL) removeSubjectWithName: (NSString*)name;
- (void) pause;
- (void) resume;
- (void) run;
- (void) terminate;

@end

