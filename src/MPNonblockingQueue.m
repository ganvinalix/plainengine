#import <MPNonblockingQueue.h>
#import <MPUtility.h>

@implementation MPNonblockingQueue

MPNonblockingQueueNode *newNode(id item)
{
	[item retain];
	MPNonblockingQueueNode *node;
	node = malloc(sizeof(MPNonblockingQueueNode));
	node->item = item;
	node->next = NULL;
	return node;
}

void freeNode(MPNonblockingQueueNode *node)
{
	[node->item release];
	free(node);
}

-init
{
	[super init];
	head = tail = newNode(nil);
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

//Michael-Scott algorithm for non-blocking concurrent FIFO queue

-(void) push: (id)elem
{
	MPNonblockingQueueNode *node = newNode(elem);
	MPNonblockingQueueNode *curTail, *residue;
	while (1)
	{
		curTail = (MPNonblockingQueueNode *)tail;
		residue = curTail->next;
		if (curTail == tail)
		{
			if (!residue)
			{
				if (MPCompareAndSwapPointer((void **)&curTail->next, NULL, node))
				{
					MPCompareAndSwapPointer((void **)&tail, curTail, node);
					return;
				}
			}
			else
			{
				MPCompareAndSwapPointer((void **)&tail, curTail, residue);
			}
		}
	}
}

-(id) pop
{
	while (1)
	{
		MPNonblockingQueueNode *oldHead, *oldTail, *first;
		oldHead = (MPNonblockingQueueNode *)head;
		oldTail = (MPNonblockingQueueNode *)tail;
		first = oldHead->next;
		if (head == oldHead)
		{
			if  (oldHead == oldTail)
			{
				if (!first)
				{
					return nil;
				}
				else
				{
					MPCompareAndSwapPointer((void **)&tail, oldTail, first);
				}
			}
			else if (MPCompareAndSwapPointer((void **)&head, oldHead, first))
			{
				id item = first->item;
				freeNode(oldHead);
				return item;
			}
		}
	}
}

@end

