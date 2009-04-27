#import <Foundation/Foundation.h>
#import <MPObject.p>

@interface MPObject : NSObject <MPObject, NSCoding>
{
	NSNumber *objectHandle;
	NSString *objectName;
	NSMutableDictionary *features;
	MPRemovalStableList *delegatesList;
	NSMutableDictionary *countPerDelegate; //delegate reference counters
	NSUInteger internalRetainCount; //Number of object system containers object is in.
									//When retainCount would be equal to internalRetainCount, object would be deallocated.
	NSRecursiveLock *accessMutex;
	BOOL removed;
}

+(void) load;

-init;
-initWithName: (NSString *)name withHandle: (NSNumber *)handle;
-(void) release;
-(void) dealloc;

+(BOOL) existsObjectWithName: (NSString *)name;

/** Removes all objects from object system */
+(void) cleanup;

-(id) getLocalDelegatePointer: (Class)delegate;

/** Creates delegate instance and adds it to object delegates array if there is no such delegate.
 	Otherwise increases internal delegate reference counter*/
-(void) setLocalDelegate: (Class)delegate;

/** Decreases "reference counter" of delegate instance. If it became equal to 0, removes it */
-(void) removeLocalDelegate: (Class)delegate;

-(NSMethodSignature *) methodSignatureForSelector: (SEL)selector;

-(void) forwardInvocation: (NSInvocation *)anInvocation;
-(BOOL) respondsToSelector: (SEL)aSelector;

-(NSUInteger) hash;
-(BOOL) isEqual: (id)anObject;

-(NSString *) description;

@end


