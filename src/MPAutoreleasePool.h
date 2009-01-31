#import <Foundation/Foundation.h>

typedef struct objectListTag
{
	id obj;
	struct objectListTag *next;
} objectList;

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

-(void) clean;

-(void) logObjects;

-(void) dealloc;

@end

