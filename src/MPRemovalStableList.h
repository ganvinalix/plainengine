#import <Foundation/Foundation.h>

typedef struct listNodeStructTag
{
	id object;
	struct listNodeStructTag *next, *prev;
	int storedCounter;
	BOOL sheduledToRemove;
} listNodeStruct;

typedef BOOL (comparisonFunction)(id, id);

typedef void* MPRemovalStableListStoredPosition;

/** Linked list, which correctly handles with item deletion while enumerating. */
@interface MPRemovalStableList : NSObject
{
	listNodeStruct *head, *tail, *cur;
}

-init;

-(void) add: (id)obj;
/** Removes object, equal to obj. (Equality is checked by 'isEqual:' call) */
-(BOOL) remove: (id)obj;
/** Removes object, equal to obj. (Equality is checked by pointers comparison) */
-(BOOL) removePointer: (id)obj;
/** Removes object, equal to obj. (Equality is checked by calling comparison function) */
-(BOOL) remove: (id)obj withComparisonFunction: (comparisonFunction)cf;

/** Returns value, where current position is stored. As you called 'storePosition:', you must call 'restorePosition:' with this pointer ONCE later.*/
-(MPRemovalStableListStoredPosition) storePosition;
/** Sets current position to position, stored by 'storePosition:'. It is important that you must not restore from one MPRemovalStableListStoredPosition twice - this might call list corruption;*/
-(void) restorePosition: (MPRemovalStableListStoredPosition)storedpos; //must be called once after 'storePosition'

/** Moves current position to begin of the list */
-(void) moveToHead;
/** Moves current position to end of the list */
-(void) moveToTail;

/** Returns current position and moves it forward to tail; Returns nil if already at tail; */
-(id) next;
/** Returns current position and moves it backwards to head; Returns nil if already at head; */
-(id) prev;

-(void) dealloc;

@end

