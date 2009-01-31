#import <Foundation/Foundation.h>
#import <MPUtility.h>

@interface MPPool : NSObject
{
	NSMutableArray *pooledObjects;
	Class pclass;
	NSUInteger capacity;
}
-init; //error

-initWithClass: (Class)aClass; 

-(id) newObject; //returns retained object

-(void) purge; //cleans pool
-(NSUInteger) size;

-(void) prepare: (NSUInteger)count; //after this operation pool size would be not less than 'count'

-(void) dealloc;
@end
