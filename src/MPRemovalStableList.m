#import <MPRemovalStableList.h>

listNodeStruct *newListNode(listNodeStruct *prev, id object)
{
	listNodeStruct *newnode;
	newnode = malloc(sizeof(listNodeStruct));
	newnode->next = NULL;
	newnode->prev = prev;
	newnode->object = [object retain];
	newnode->storedCounter = 0;
	newnode->sheduledToRemove = NO;
	return newnode;
}

void deleteListNode(listNodeStruct *node)
{
	if (node->prev)
	{
		node->prev->next = node->next;
	}
	if (node->next)
	{
		node->next->prev = node->prev;
	}
	[node->object release];
	free(node);
}

@implementation MPRemovalStableList

-(void) setCurrent: (listNodeStruct *)c
{
	if (cur)
	{
		--(cur->storedCounter);
		NSAssert(cur->storedCounter >= 0, @"storedCounter became negative");
		if (!(cur->storedCounter) && cur->sheduledToRemove)
		{
			deleteListNode(cur);
		}
	}
	cur = c;
	if (c)
	{
		++(c->storedCounter);
	}
}

-init
{
	[super init];
	head = tail = cur = NULL;
	return self;
}

-(void) add: (id)obj
{
	if (!obj)
	{
		return;
	}

	if (head)
	{
		listNodeStruct *newnode;
		tail->next = newnode = newListNode(tail, obj);
		tail = newnode;
	}
	else
	{
		head = newListNode(NULL, obj);
		tail = head;
		[self setCurrent: head];
	}
}


-(BOOL) remove: (id)obj withComparisonFunction: (comparisonFunction)cf;
{
	if (!obj)
	{
		return NO;
	}
	BOOL found = NO;
	listNodeStruct *node;
	node = head;
	while (node)
	{
		if (cf(node->object, obj))
		{
			if (node->storedCounter)
			{
				[node->object release];
				node->object = nil;
				node->sheduledToRemove = YES;
			}
			else
			{
				if (head == node)
				{
					head = node->next;
				}
				if (tail == node)
				{
					tail = node->prev;
				}
				deleteListNode(node);
			}
			found = YES;
		}
		node = node->next;
	}
	return found;
}

BOOL compareObjects(id obj1, id obj2)
{
	return [obj1 isEqual: obj2];
}

BOOL comparePointers(id obj1, id obj2)
{
	return obj1 == obj2;
}

-(BOOL) remove: (id)obj
{
	return [self remove: obj withComparisonFunction: compareObjects];
}

-(BOOL) removePointer: (id)obj
{
	return [self remove: obj withComparisonFunction: comparePointers];
}

-(MPRemovalStableListStoredPosition) storePosition
{
	if (cur)
	{
		++(cur->storedCounter);
	}
	return cur;
}

-(void) restorePosition: (MPRemovalStableListStoredPosition)storedpos
{
	[self setCurrent: storedpos];
	if (cur)
	{
		--(cur->storedCounter);
		NSAssert(cur->storedCounter >= 0, @"storedCounter became negative");
	}
}

-(void) moveToHead
{
	[self setCurrent: head];
}

-(void) moveToTail
{
	[self setCurrent: tail];
}

-(id) next
{
	id obj = nil;

	if (cur)
	{
		do
		{
			obj = cur->object;
			[self setCurrent: cur->next];
		}
		while (cur && !obj);
	}

	return obj;
}

-(id) prev
{
	id obj = nil;

	if (cur)
	{
		do
		{
			obj = cur->object;
			[self setCurrent: cur->prev];
		}
		while (cur && !obj);
	}

	return obj;
}

-(void) dealloc
{
	listNodeStruct *node;
	while (head)
	{
		node = head;
		head = head->next;
		deleteListNode(node);
	}
	[super dealloc];
}

@end

