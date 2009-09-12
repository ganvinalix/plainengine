#import <Foundation/Foundation.h>
#import <MPQueue.p>

typedef struct MPNonblockingQueueNode_tag
{
	id item;
	struct MPNonblockingQueueNode_tag *next;
} MPNonblockingQueueNode;

@interface MPNonblockingQueue: NSObject <MPQueue>
{
	volatile MPNonblockingQueueNode *head;	
	volatile MPNonblockingQueueNode *tail;
}

-init;
-(void) dealloc;

@end

