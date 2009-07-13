#import <Foundation/Foundation.h>

typedef struct objectListTag
{
	id obj;
	struct objectListTag *next;
} objectList;

/** NSAutoreleasePool analogue which supports cleaning and logging */
@interface MPAutoreleasePool : NSAutoreleasePool
{
	//NSMutableArray *objects;
	objectList *head;
	objectList *tail;
	NSUInteger size;
}

+new;
-init;

-(void) addObject: (id)object;
-(NSUInteger) size;

/** Cleans autorelease pool of objects, releasing them */
-(void) clean;

/** Prints autorelease pool contents */
-(void) logObjects;

-(void) dealloc;

@end

