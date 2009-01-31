#import <common.h>
#import <MPAPI.p>
#import <MPThread.h>
#import <MPUtility.h>

@interface MPAPI : NSObject <MPAPI>
{
@private
	MPThread *_thread;
	MPPool *emptyDictionaryPool;
}
+ api;
- (void) setCurrentThread: (MPThread *)aThread;

@end

