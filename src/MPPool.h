#import <Foundation/Foundation.h>
#import <MPUtility.h>

/**
  <p>This class is a pool implementation. It should be used when there are many objects
  that are often being created and destroyed and you want to optimize memory usage.</p>
  <p>MPPool must be created with [[MPPool alloc] initWithClass: class], where class
  is class of objects that MPPool should manage and not with [[MPPool alloc] init].</p>
  <p>MPPool creates objects with [class new].</p>
  <p>Important: object recieved by [pool newObject] may be not "clean", because it could be used before.</p>
  */
@interface MPPool : NSObject
{
	NSMutableArray *pooledObjects;
	Class pclass;
	NSUInteger capacity;
}
/** Error */
-init;

/** Initialization */
-initWithClass: (Class)aClass; 

/** Returns new or unused object (detected by retainCount) */
-(id) newObject;

/** Cleans pool */
-(void) purge;
/** Returns number of objects in pool */
-(NSUInteger) size;

/** After this operation pool size would be not less than count*/
-(void) prepare: (NSUInteger)count;

-(void) dealloc;
@end
