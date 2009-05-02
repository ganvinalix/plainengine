#import <Foundation/Foundation.h>
#import <MPObject.p>
#import <universal_delegate_headers.h>

typedef NSMethodSignature *(*delegateMethodSignatureGetter)(char const* methodName, void *userInfo, void *classInfo);

#define DECLARE_DELEGATE_METHODSIGNATUREGETTER(name)\
	NSMethodSignature *name(char const *methodName, void *userInfo, void *classInfo)

@interface MPUniversalDelegateClassObject: NSObject
{
@private
	delegateInitFunc initFunc;
	delegateCleanFunc cleanFunc;
	delegateSetFeatureFunc sfFunc;
	delegateRemoveFeatureFunc rfFunc;

	NSUInteger userInfoLength;
	NSUInteger index;
	NSMutableDictionary *namePerMethodDescriptor;
	void *classInfo;
	NSLock *accessMutex;
@public
	delegateMethod universalMethod;
	delegateUniversalMethodReturnType universalMethodRetTypeFunc;
	delegateUniversalMethodParams universalMethodParamsFunc;
	delegateResponseChecker universalMethodRespChkFunc;
	delegateMethodSignatureGetter universalMethodSignatureGetterFunc;
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

//removes last set method
-(void) setUniversalMethod: (delegateMethod)delMeth
   withResponseCheckerFunc: (delegateResponseChecker)respChk
		withReturnTypeFunc: (delegateUniversalMethodReturnType)retTypeFunc
		withParamsTypeFunc: (delegateUniversalMethodParams)paramsFunc;

-(void) setUniversalMethod: (delegateMethod)delMeth
   withMethodSignatureFunc: (delegateMethodSignatureGetter)delSigGetter;

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

-(void) lock;
-(void) unlock;

-(oneway void) release;
-(void) dealloc;

@end

