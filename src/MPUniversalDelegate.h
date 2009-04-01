#import <Foundation/Foundation.h>
#import <MPObject.p>
#import <universal_delegate_headers.h>

@interface MPUniversalDelegateClassObject: NSObject
{
	delegateInitFunc initFunc;
	delegateCleanFunc cleanFunc;
	delegateSetFeatureFunc sfFunc;
	delegateRemoveFeatureFunc rfFunc;
	NSUInteger userInfoLength;
	NSUInteger index;
	NSMutableDictionary *namePerMethodDescriptor;
	void *classInfo;
	NSLock *accessMutex;
}

+registerDelegateClassWithInitFunc: (delegateInitFunc)anInitFunc
					 withCleanFunc: (delegateCleanFunc)aCleanFunc
				withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
			 withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
				withUserInfoLength: (NSUInteger)anUserInfoLength;

+registerDelegateClassWithInitFunc: (delegateInitFunc)anInitFunc
					 withCleanFunc: (delegateCleanFunc)aCleanFunc
				withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
			 withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
				withUserInfoLength: (NSUInteger)anUserInfoLength
					 withClassInfo: (void *)aClassInfo;

-(void) registerDelegateMethod: (delegateMethod)delMeth
				withReturnType: (char const *)returnType
		  withDelegateSelector: (char const *)delSel
				withParamsType: (char const *)paramType;

//---------------------------------------------------------

-init; //error

-initWithInitFunc:		(delegateInitFunc)anInitFunc
		 withCleanFunc: (delegateCleanFunc)aCleanFunc
    withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
 withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
	withUserInfoLength: (NSUInteger)anUserInfoLength
		 withClassInfo: (void *)aClassInfo;

-(void *) classInfo;

-newDelegateWithObject: (id<MPObject>)anObject;

-(BOOL) isEqual: (id)anObject;
-copyWithZone: (NSZone *)zone;

-(NSUInteger) retainCount;

-(oneway void) release;
-(void) dealloc;

@end

