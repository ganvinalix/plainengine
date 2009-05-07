#import <MPUniversalDelegate.h>
#import <MPUtility.h>
#import <limits.h>

NSUInteger globalIndexCounter = 1;
NSLock *commonMutex = nil;

@interface MPUniversalDelegateMethodDescriptor: NSObject
{
	delegateMethod methodImpl;
	char const *returnType;
	char const *paramsType;
	NSMethodSignature *sig;
}
-init;
-initWithMethodImpl: (delegateMethod)anImpl
	 withReturnType: (char const *)aReturnType
	 withParamsType: (char const *)aParamsType;


-(delegateMethod) getImplementation;
-(void) dealloc;

-(NSMethodSignature *) methodSignature;
@end

@implementation MPUniversalDelegateMethodDescriptor

-init
{
	NSAssert(0, @"Attempt to create MPUniversalDelegateMethodDescriptor without params");
	return nil;
}

-initWithMethodImpl: (delegateMethod)anImpl
	 withReturnType: (char const *)aReturnType
	 withParamsType: (char const *)aParamsType
{
	[super init];
	methodImpl = anImpl;
	returnType = aReturnType;
	paramsType = aParamsType;

	char *sigTypes;
	sigTypes = malloc(strlen(returnType)+strlen(paramsType)+3);
	sprintf(sigTypes, "%s@:%s", returnType, paramsType);
	sig = [[NSMethodSignature signatureWithObjCTypes: sigTypes] retain];
	free(sigTypes); 

	return self;
}

-(delegateMethod) getImplementation
{
	return methodImpl;
}

-(void) dealloc
{
	[sig release];
	[super dealloc];
}

-(NSMethodSignature *) methodSignature
{
	return sig;
}

@end

@interface MPUniversalDelegate: NSObject
{
	MPUniversalDelegateClassObject *delegateClass;
	void *userInfo;
	void *classInfo;
	delegateCleanFunc cleanFunc;
	delegateSetFeatureFunc sfFunc;
	delegateRemoveFeatureFunc rfFunc;
	NSUInteger userInfoLength;
	NSDictionary *namePerMethodDescriptor; //pointer to analogical dictionary in class object
	
	NSUInteger universalMethodSigLength;
	char *universalMethodSigBuf;

	NSUInteger resultBufferLength;
	void *resultBuffer;

	NSUInteger argsCount;
	NSUInteger *argBufSize;
	void **argBufArray;

}

-init; //returns error

-initWithClassObject:	   (MPUniversalDelegateClassObject *)aDelegateClass
			 withInitFunc: (delegateInitFunc)anInitFunc
			withCleanFunc: (delegateCleanFunc)aCleanFunc
	   withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
	withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
	   withUserInfoLength: (NSUInteger)anUserInfoLength
		   withMethodDict: (NSDictionary *)aMethodDict
			   withObject: (id)anObject;

-(Class) class;
-(BOOL) isKindOfClass: (Class)aClass;
-(BOOL) isMemberOfClass: (Class)aClass;

-(BOOL) respondsToSelector: (SEL)aSelector;
-(NSMethodSignature *) methodSignatureForSelector: (SEL)aSelector;
-(void) forwardInvocation: (NSInvocation *)anInvocation;

-(void) setFeature: (NSString *)name toValue: (id<MPVariant>)data userInfo: (MPCDictionaryRepresentable *)userDict;
-(void) removeFeature: (NSString *)name userInfo: (MPCDictionaryRepresentable *)userDict;

-(void) dealloc;

@end

@implementation MPUniversalDelegate

-init
{
	NSAssert(0, @"MPUniversalDelegate init without params");
	return nil;
}

-initWithClassObject:	   (MPUniversalDelegateClassObject *)aDelegateClass
			 withInitFunc: (delegateInitFunc)anInitFunc
			withCleanFunc: (delegateCleanFunc)aCleanFunc
	   withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
	withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
	   withUserInfoLength: (NSUInteger)anUserInfoLength
		   withMethodDict: (NSDictionary *)aMethodDict
			   withObject: (id)anObject
{
	[super init];
	delegateClass = aDelegateClass;
	cleanFunc = aCleanFunc;
	sfFunc = aSFFunc;
	rfFunc = aRFFunc;
	userInfoLength = anUserInfoLength;
	namePerMethodDescriptor = aMethodDict;
	classInfo = [delegateClass classInfo];
	userInfo = userInfoLength ? malloc(userInfoLength) : NULL;

	resultBufferLength = 0;
	resultBuffer = NULL;

	argsCount = 0;
	argBufSize = NULL;
	argBufArray = NULL;

	universalMethodSigLength = 0;
	universalMethodSigBuf = NULL;

	if (anInitFunc)
	{
		anInitFunc(userInfo, [[anObject getHandle] MPHANDLE_VALUE], classInfo);
	}
	return self;
}

-(Class) class
{
	return (Class)delegateClass;
}

-(BOOL) isKindOfClass: (Class)aClass
{
	if ((id)aClass == delegateClass)
	{
		return YES;
	}
	else
	{
		return [super isKindOfClass: aClass];
	}
}

-(BOOL) isMemberOfClass: (Class)aClass
{
	return (id)aClass == delegateClass;
}

-(BOOL) respondsToSelector: (SEL)aSelector
{
	if ([super respondsToSelector: aSelector])
	{
		return YES;
	}
	if ([namePerMethodDescriptor objectForKey: NSStringFromSelector(aSelector)] != nil)
	{
		return YES;
	}
	[delegateClass lock];
	if (delegateClass->universalMethod)
	{
		if (delegateClass->universalMethodRespChkFunc)
		{
			[delegateClass unlock];
			return delegateClass->universalMethodRespChkFunc(sel_getName(aSelector), userInfo, classInfo) != 0;
		}
		else
		{
			[delegateClass unlock];
			return delegateClass->universalMethodSignatureGetterFunc(sel_getName(aSelector), userInfo, classInfo) != nil;
		}
	}
	[delegateClass unlock];
	return NO;
}

-(NSMethodSignature *) methodSignatureForSelector: (SEL)aSelector
{
	NSMethodSignature *sig = [super methodSignatureForSelector: aSelector];
	const char *selUTF8String = sel_getName(aSelector);
	if (sig)
	{
		return sig;
	}
	if ((sig = [[namePerMethodDescriptor objectForKey: NSStringFromSelector(aSelector)] methodSignature]) != nil )
	{
		return sig;
	}
	[delegateClass lock];
	if (delegateClass->universalMethod)
	{
		if (delegateClass->universalMethodRespChkFunc)
		{
			if (!(delegateClass->universalMethodRespChkFunc(selUTF8String, userInfo, classInfo)))
			{
				[delegateClass unlock];
				return nil;
			}
			delegateUniversalMethodReturnType retTypeFunc = delegateClass->universalMethodRetTypeFunc;
			delegateUniversalMethodParams paramsFunc = delegateClass->universalMethodParamsFunc;
			[delegateClass unlock];
			const char *paramsType = paramsFunc(selUTF8String, userInfo, classInfo);
			const char *returnType = retTypeFunc(selUTF8String, userInfo, classInfo);
			NSUInteger size = strlen(returnType) + strlen(paramsType) + 3;
			if (size > universalMethodSigLength)
			{
				universalMethodSigBuf = realloc(universalMethodSigBuf, size);
				universalMethodSigLength = size;
			}
			sprintf(universalMethodSigBuf, "%s@:%s", returnType, paramsType);
			sig = [NSMethodSignature signatureWithObjCTypes: universalMethodSigBuf];
			return sig;
		}
		else
		{
			delegateMethodSignatureGetter methodSignatureGetter = delegateClass->universalMethodSignatureGetterFunc;
			[delegateClass unlock];
			return methodSignatureGetter(selUTF8String, userInfo, classInfo);
		}
	}
	[delegateClass unlock];
	return nil;
}

-(void) setFeature: (NSString *)name toValue: (id<MPVariant>)data userInfo: (MPCDictionaryRepresentable *)userDict
{
	if (sfFunc)
	{
		if (!userDict)
		{
			userDict = [MPDictionary dictionary];
		}
		sfFunc(userInfo, [name UTF8String], [[data stringValue] UTF8String], [userDict getCDictionary], classInfo);
	}
}

-(void) removeFeature: (NSString *)name userInfo: (MPCDictionaryRepresentable *)userDict
{
	if (rfFunc)
	{
		if (!userDict)
		{
			userDict = [MPDictionary dictionary];
		}
		rfFunc(userInfo, [name UTF8String], [userDict getCDictionary], classInfo);
	}
}

-(void) forwardInvocation: (NSInvocation *)anInvocation
{
	[delegateClass lock];
	delegateMethod universalMethod = delegateClass->universalMethod;
	delegateUniversalMethodReturnType universalMethodReturnType = delegateClass->universalMethodRetTypeFunc;
	delegateUniversalMethodParams universalMethodParams = delegateClass->universalMethodParamsFunc;
	delegateMethodSignatureGetter signatureGetter = delegateClass->universalMethodSignatureGetterFunc;
	delegateResponseChecker respChecker = delegateClass->universalMethodRespChkFunc;
	[delegateClass unlock];
	SEL aSelector = [anInvocation selector];
	NSString *selName = NSStringFromSelector(aSelector);
	const char *selUTF8String = [selName UTF8String];
	NSMethodSignature *sig = nil;
	delegateMethod impl = NULL;
	
	MPUniversalDelegateMethodDescriptor *descriptor = [namePerMethodDescriptor objectForKey: selName];
	if (descriptor)
	{
		sig = [descriptor methodSignature];
		impl = [descriptor getImplementation];
	}
	else
	{
		if (!(impl = universalMethod))
		{
			[super forwardInvocation: anInvocation];
			return;
		}
		if (signatureGetter)
		{
			sig = signatureGetter(selUTF8String, userInfo, classInfo);
			if (!sig)
			{
				return;
			}
		}
		else if (respChecker(selUTF8String, userInfo, classInfo))
		{
			const char *returnType = universalMethodReturnType(selUTF8String, userInfo, classInfo);
			const char *paramsType = universalMethodParams(selUTF8String, userInfo, classInfo);
			NSUInteger size = strlen(returnType) + strlen(paramsType) + 3;
			if (size > universalMethodSigLength)
			{
				universalMethodSigBuf = realloc(universalMethodSigBuf, size);
				universalMethodSigLength = size;
			}
			sprintf(universalMethodSigBuf, "%s@:%s", returnType, paramsType);
			sig = [NSMethodSignature signatureWithObjCTypes: universalMethodSigBuf];
		}
	}
	NSUInteger curArgsCount = [sig numberOfArguments]-2;
	if (argsCount < curArgsCount)
	{
		argBufArray = realloc(argBufArray, curArgsCount*sizeof(void *));
		argBufSize = realloc(argBufSize, curArgsCount*sizeof(NSUInteger));
		for (; argsCount < curArgsCount; ++argsCount) //nulling just now allocated memory
		{
			argBufArray[argsCount] = NULL;
			argBufSize[argsCount] = 0;
		}
	}
	NSUInteger i;
	for (i=0; i<curArgsCount; ++i)
	{
		NSUInteger size;
		NSGetSizeAndAlignment([sig getArgumentTypeAtIndex: i+2], &size, NULL);
		if (argBufSize[i] < size)
		{
			argBufSize[i] = size;
			argBufArray[i] = realloc(argBufArray[i], size);
		}
		[anInvocation getArgument: argBufArray[i] atIndex: i+2];
	}
	NSUInteger curResultBufferLength = [sig methodReturnLength];
	if (resultBufferLength < curResultBufferLength)
	{
		resultBufferLength = curResultBufferLength;
		resultBuffer = realloc(resultBuffer, resultBufferLength);
	}
	impl(selUTF8String, userInfo, argBufArray, resultBuffer, classInfo);
	[anInvocation setReturnValue: resultBuffer];
}

-(void) dealloc
{
	if (cleanFunc)
	{
		cleanFunc(userInfo, classInfo);
	}
	free(userInfo);
	[super dealloc];
}

@end

@implementation MPUniversalDelegateClassObject

+(void) load
{
	commonMutex = [NSLock new];
}

+registerDelegateClassWithInitFunc: (delegateInitFunc)anInitFunc
					 withCleanFunc: (delegateCleanFunc)aCleanFunc
				withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
			 withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
				withUserInfoLength: (NSUInteger)anUserInfoLength
{
	return [[self alloc] initWithInitFunc: anInitFunc
							withCleanFunc: aCleanFunc
					   withSetFeatureFunc: aSFFunc
					withRemoveFeatureFunc: aRFFunc
					   withUserInfoLength: anUserInfoLength
							withClassInfo: NULL]; //class object must remain until program end, so we do not release here;
}

+registerDelegateClassWithInitFunc: (delegateInitFunc)anInitFunc
					 withCleanFunc: (delegateCleanFunc)aCleanFunc
				withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
			 withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
				withUserInfoLength: (NSUInteger)anUserInfoLength
					 withClassInfo: (void *)aClassInfo
{

	return [[self alloc] initWithInitFunc: anInitFunc
							withCleanFunc: aCleanFunc
					   withSetFeatureFunc: aSFFunc
					withRemoveFeatureFunc: aRFFunc
					   withUserInfoLength: anUserInfoLength
							withClassInfo: aClassInfo]; //class object must remain until program end, so we do not release here;
}

-(void) registerDelegateMethod: (delegateMethod)delMeth
				withReturnType: (char const *)returnType
		  withDelegateSelector: (char const *)delSel
				withParamsType: (char const *)paramType
{
	sel_registerName(delSel);

	MPUniversalDelegateMethodDescriptor *descriptor;
	descriptor = [[MPUniversalDelegateMethodDescriptor alloc] initWithMethodImpl: delMeth
																  withReturnType: returnType
																  withParamsType: paramType];


	NSString *selName = [NSString stringWithFormat: @"%s", delSel];

	[accessMutex lock];
	[namePerMethodDescriptor setObject: descriptor forKey: selName];
	[accessMutex unlock];

	[descriptor release]; //give ownership to dictionary;

	NSAssert1(substringCount(selName, @":") == [[descriptor methodSignature] numberOfArguments]-2,
											@"Number of arguments is not equal to number of \":\" in selector \"%@\"", selName);
}

-(void) setUniversalMethod: (delegateMethod)delMeth
   withResponseCheckerFunc: (delegateResponseChecker)respChk
		withReturnTypeFunc: (delegateUniversalMethodReturnType)retTypeFunc
		withParamsTypeFunc: (delegateUniversalMethodParams)paramsFunc
{
	[accessMutex lock];
	universalMethod = delMeth;
	universalMethodRetTypeFunc = retTypeFunc;
	universalMethodParamsFunc = paramsFunc;
	universalMethodRespChkFunc = respChk;
	universalMethodSignatureGetterFunc = NULL;
	[accessMutex unlock];
}


-(void) setUniversalMethod: (delegateMethod)delMeth
   withMethodSignatureFunc: (delegateMethodSignatureGetter)delSigGetter
{
	universalMethod = delMeth;
	universalMethodRetTypeFunc = NULL;
	universalMethodParamsFunc = NULL;
	universalMethodRespChkFunc = NULL;
	universalMethodSignatureGetterFunc = delSigGetter;
}


-init
{
	NSAssert(0, @"MPUniversalDelegateClassObject init without params");
	return nil;
}


-initWithInitFunc:		(delegateInitFunc)anInitFunc
		 withCleanFunc: (delegateCleanFunc)aCleanFunc
    withSetFeatureFunc: (delegateSetFeatureFunc)aSFFunc
 withRemoveFeatureFunc: (delegateRemoveFeatureFunc)aRFFunc
	withUserInfoLength: (NSUInteger)anUserInfoLength
		 withClassInfo: (void *)aClassInfo
{
	[super init];
	initFunc = anInitFunc;
	cleanFunc = aCleanFunc;
	sfFunc = aSFFunc;
	rfFunc = aRFFunc;
	classInfo = aClassInfo;
	userInfoLength = anUserInfoLength;
	accessMutex = [NSLock new];
	namePerMethodDescriptor = [NSMutableDictionary new];
	[commonMutex lock];
	index = globalIndexCounter++;
	[commonMutex unlock];

	universalMethod = NULL;
	universalMethodRetTypeFunc = NULL;
	universalMethodParamsFunc = NULL;
	universalMethodRespChkFunc = NULL;
	universalMethodSignatureGetterFunc = NULL;

	return self;
}

-newDelegateWithObject: (id<MPObject>)anObject
{
	MPUniversalDelegate *delegate;
	delegate = [[MPUniversalDelegate alloc] initWithClassObject: self
												   withInitFunc: initFunc
												  withCleanFunc: cleanFunc
											 withSetFeatureFunc: sfFunc
										  withRemoveFeatureFunc: rfFunc
											 withUserInfoLength: userInfoLength
												 withMethodDict: namePerMethodDescriptor
													 withObject: anObject];
	return delegate;
}

-(void *) classInfo
{
	return classInfo;
}

-(NSUInteger) index
{
	return index;
}

-(BOOL) isEqual: (id)anObject
{
	if (![anObject isKindOfClass: [self class]])
	{
		return NO;
	}
	return index == [anObject index];
}

-(NSUInteger) retainCount
{
	return UINT_MAX; //As it is told it NSObject protocol specifications
}

-(void) lock
{
	[accessMutex lock];
}

-(void) unlock
{
	[accessMutex unlock];
}

-(oneway void) release
{
	//Once registered, delegate class would never be deallocated
}

-(void) dealloc
{
	NSAssert(0, @"dealloc of MPUniversalDelegateClassObject must not be called");
	[super dealloc];
}

-copyWithZone: (NSZone *)zone
{
	return self;
}

@end

