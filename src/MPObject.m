#import <Foundation/Foundation.h>
#import <common.h>
#import <core_constants.h>
#import <MPObject.h>
#import <MPNotifications.h>
#import <MPUtility.h>

id handleToString(id handle)
{
	return [handle stringValue];
}

MPMapper *handleMapper; //handle-to-string cache
MPHandle handleCounter; //global handle counter to provide unique handles
NSUInteger defaultNameCount; //default name counter to provide unique default names
NSMutableArray *delegatesArray; //array of global delegate classes
NSMutableDictionary *delegatesByFeature; //dictionary which maps array of delegate classes to feature
NSMutableDictionary *featuresByDelegate; //dictionary which maps to delegate class array of features, for which this delegate class is registered
NSMutableDictionary *delegateClassPerUserInfo; //dictionary which maps MPUserInfoWrapper to delegate class
NSMutableArray *objectsArray; //array of all objects
NSMutableDictionary *objectsByFeature; //dictionary which maps to feature array of objects having this feature
NSMutableDictionary *objectByHandle; //dictionary which maps object to its handle
NSMutableDictionary *objectByName; //dictionary which maps object to its name
NSRecursiveLock *objectClassMutex; //global mutex

//this protocol isn't being used. It is need just to declare some selectors.
@protocol MPObjectDelegateClassDeclarations
+newDelegateWithObject: (id)anObject;
+newDelegateWithObject: (id)anObject withUserInfo: (void *)anUserInfo;
@end

@interface MPUserInfoWrapper: NSObject
{
	void *userInfo;
}

-init;
-initWithUserInfo: (void *)anUserInfo;
-(void *) getUserInfo;

@end

@implementation MPUserInfoWrapper

-init
{
	return [self initWithUserInfo: NULL];
}

-initWithUserInfo: (void *)anUserInfo
{
	[super init]; 
	userInfo = anUserInfo;
	return self;
}

-(void *) getUserInfo
{
	return userInfo;
}

@end

@interface MPCounter: NSObject
{
@public
	NSUInteger value;
}
-init;
@end

@implementation MPCounter

-init
{
	value = 1;
	return [super init];
}

@end

@implementation MPObject

/* Here some useful macroses are defined:
 *
 * (all ...LOCK and ...UNLOCK are exception-safe if compiled with MP_USE_EXCEPTIONS and no-op if compiled without MP_USE_EXCEPTIONS)
 * MPO_LOCK - locks current object if need
 * MPO_UNLOCK - unlocks current object if need (paired with MPO_LOCK)
 * MPO_TUNLOCK - temporary unlock current object with saving delegate list position
 * MPO_TLOCK - paired to MPO_TUNLOCK. Locks again object and restores delegate list position
 * MPOC_LOCK - locks global mutex
 * MPOC_UNLOCK - unlocks global mutex
 */

#ifndef MPOBJECT_ENABLESYNCHRONISATION

#define MPO_LOCK
#define MPO_UNLOCK
#define MPO_TLOCK
#define MPO_TUNLOCK
#define MPOC_LOCK
#define MPOC_UNLOCK

#else

#define MPO_TUNLOCK\
	{\
		MPRemovalStableListStoredPosition __pos = [delegatesList storePosition];\
		[accessMutex unlock];

#define MPO_TLOCK\
		[accessMutex lock];\
		[delegatesList restorePosition: __pos];\
	}

#ifdef MP_USE_EXCEPTIONS

#define MPO_LOCK \
	[accessMutex lock];\
	@try\
	{

#define MPO_UNLOCK \
	}\
	@finally\
	{\
		[accessMutex unlock];\
	}\

#define MPOC_LOCK \
	[objectClassMutex lock];\
	@try\
	{

#define MPOC_UNLOCK \
	}\
	@finally\
	{\
		[objectClassMutex unlock];\
	}\

#else

#define MPO_LOCK \
	[accessMutex lock];\
	{

#define MPO_UNLOCK \
	}\
	[accessMutex unlock];

#define MPOC_LOCK \
	[objectClassMutex lock];\
	{

#define MPOC_UNLOCK \
	}\
	[objectClassMutex unlock];

#endif

#endif

#ifdef MPOBJECT_DETAILLOGGING
	#define MPO_DETAILLOG(x) [gLog add: info withFormat: x]
#else
	#define MPO_DETAILLOG(x) 
#endif

//==================================================

+(void) load
{
	handleMapper = [[MPMapper alloc] initWithConverter: &handleToString];
	defaultNameCount = 0;
	handleCounter = 0;
	delegatesArray = [NSMutableArray new];
	delegatesByFeature = [NSMutableDictionary new];
	delegateClassPerUserInfo = [NSMutableDictionary new];
	featuresByDelegate = [NSMutableDictionary new];
	objectsArray = [NSMutableArray new];
	objectByHandle = [NSMutableDictionary new];
	objectByName = [NSMutableDictionary new];
	objectsByFeature = [NSMutableDictionary new];
	objectClassMutex = [NSRecursiveLock new];
}

+(void) cleanup
{
	MPOC_LOCK;
	MPO_DETAILLOG(@"MPObject: cleanup started");

	MPO_DETAILLOG(@"MPObject: cleanup phase 1 (cleaning internal reference counter of all objects)");
	NSUInteger i, count = [objectsArray count];
	for (i=0;i<count;++i)
	{
		((MPObject *)[objectsArray objectAtIndex: i])->internalRetainCount=0;
	}

	MPO_DETAILLOG(@"MPObject: cleanup phase 2 (deregistering all objects)");
	[objectByHandle removeAllObjects];
	[objectByName removeAllObjects];
	[objectsByFeature removeAllObjects];
	[objectsArray removeAllObjects];

	MPO_DETAILLOG(@"MPObject: cleanup finished");
	MPOC_UNLOCK;
}

+(BOOL) existsObjectWithName: (NSString *)name
{
	return [MPObject getObjectByName: name] != nil;
}

+newObjectWithName: (NSString *)name
{
	return [[self alloc] initWithName: name];
}

-init
{
	NSMutableString *newName = [NSMutableString new];
	[newName appendFormat: @"object%llu", handleCounter++];
	id obj = [self initWithName: newName];
	[newName release];
	return obj;
}

-initWithName: (NSString *)aName
{
	return [self initWithName: aName withHandle: [[[NSNumber alloc] INIT_WITH_MPHANDLE: handleCounter++] autorelease]];
}

-initWithName: (NSString *)aName withHandle: (NSNumber *)handle
{
	[super init];
	objectHandle = [handle copy];
	objectName = [aName copy];
	features = [NSMutableDictionary new];
	delegatesList = [MPRemovalStableList new];
	accessMutex = [NSRecursiveLock new];
	countPerDelegate = [NSMutableDictionary new];
	removed = NO;
	internalRetainCount = 0;
	id obj;
	if ((obj = [MPObject getObjectByName: aName]) != nil)
	{
		[gLog add: warning withFormat: @"Attempt to recreate object \"%@\"", aName];
		removed = YES;
		[self release];
		return [obj retain];
	}
	else
	{
		MPOC_LOCK;
		[objectsArray addObject: self];
		[objectByHandle setObject: self forKey: objectHandle];
		[objectByName setObject: self forKey: objectName];
		internalRetainCount += 3;

		//enumerate delegates and call setLocalDelegate;
		NSUInteger i, count = [delegatesArray count];
		for (i=0; i<count; ++i)
		{
			[self setLocalDelegate: [delegatesArray objectAtIndex: i]];
		}
		MPOC_UNLOCK;

		MPDictionary *params = [[MPDictionary alloc] initWithObjectsAndKeys:
			objectName,								MPParamObjectName,
			[handleMapper getObject: objectHandle],	MPParamObjectHandle,
			nil];
		MPPostNotification(MPObjectCreatedMessage, params);
		[params release];

		#ifdef MPOBJECT_DETAILLOGGING
		[gLog add: info withFormat: @"MPObject: object created: \"%@\" [%@]", objectName, handle];
		#endif

		return self;
	}
}

-(id) getLocalDelegatePointer: (Class)delegate
{
	MPRemovalStableListStoredPosition *storedPos = [delegatesList storePosition];
	[delegatesList moveToHead];
	id del;
	while ((del = [delegatesList next]) != nil)
	{
		if ([del isMemberOfClass: delegate])
		{
			[delegatesList restorePosition: storedPos];
			return del;		
		}
	}
	[delegatesList restorePosition: storedPos];
	return nil;
}

-(void) setLocalDelegate: (Class)delegate
{
	MPCounter *cntr = [countPerDelegate objectForKey: delegate];
	if (cntr && (cntr->value))
	{
		#ifdef MPOBJECT_DETAILLOGGING
		[gLog add: info withFormat: @"MPObject: local delegate \"%@\" of object \"%@\" reference counter increased;",
			delegate, self];
		#endif
		++(cntr->value);
		return;
	}

	MPO_LOCK;
	cntr = [MPCounter new];
	[countPerDelegate setObject: cntr forKey: delegate];
	[cntr release];
	id localDelegate;

	if ([delegate respondsToSelector: @selector(newDelegateWithObject:withUserInfo:)])
	{
		localDelegate = [delegate newDelegateWithObject: self
										   withUserInfo: [[delegateClassPerUserInfo objectForKey: delegate] getUserInfo]];
	}
	else if ([delegate respondsToSelector: @selector(newDelegateWithObject:)])
	{
		localDelegate = [delegate newDelegateWithObject: self];
	}
	else
	{
		localDelegate = [delegate new];
	}
	[delegatesList add: localDelegate];
	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: local delegate \"%@\" of object \"%@\" added;",
		delegate, self];
	#endif
	[localDelegate release];
	MPO_UNLOCK;
}

-(void) removeLocalDelegate: (Class)delegate
{
	MPCounter *cntr = [countPerDelegate objectForKey: delegate];
	if (!cntr)
	{
		return;
	}
	MPO_LOCK;
	--(cntr->value);
	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: local delegate \"%@\" of object \"%@\" reference counter decreased;",
		delegate, self];
	#endif
	if (!(cntr->value))
	{
		if ([delegatesList removePointer: [self getLocalDelegatePointer: delegate]])
		{
			#ifdef MPOBJECT_DETAILLOGGING
			[gLog add: info withFormat: @"MPObject: local delegate \"%@\" of object \"%@\" removed;",
				delegate, self];
			#endif
		}
	}
	MPO_UNLOCK;
}

+(void) registerDelegate: (Class)delegate
{
	MPOC_LOCK;
	NSUInteger oldindex = [delegatesArray indexOfObject: delegate];
	if (oldindex == NSNotFound)
	{
		[delegatesArray addObject: delegate];
		NSArray *objects = [MPObject getAllObjects];
		NSUInteger i, count = [objects count];
		for (i=0; i<count; ++i)
		{
			[[objects objectAtIndex: i] setLocalDelegate: delegate];
		}
		[gLog add: notice withFormat: @"MPObject: delegate \"%@\" added;", delegate];
	}
	else
	{
		[gLog add: warning withFormat: @"MPObject: attempt to re-add delegate \"%@\";", delegate];
	}
	MPOC_UNLOCK;
}

+(BOOL) removeDelegate: (Class)delegate
{
	NSUInteger oldindex = [delegatesArray indexOfObject: delegate];
	if (oldindex != NSNotFound)
	{
		NSArray *objects;
		/* TODO: remove this code
		MPOC_LOCK;
		objects = [[MPObject getAllObjects] copy];
		MPOC_UNLOCK;
		*/

		objects = [MPObject getAllObjects];
		MPOC_LOCK;
		NSUInteger i, count = [objects count];
		for (i=0; i<count; ++i)
		{
			[[objects objectAtIndex: i] removeLocalDelegate: delegate];
		}
		[delegatesArray removeObject: delegate];
		MPOC_UNLOCK;

		[objects release];
		[gLog add: notice withFormat: @"MPObject: delegate \"%@\" removed;", delegate];
		return YES;
	}
	else
	{
		[gLog add: warning withFormat: @"MPObject: attempt to remove delegate \"%@\" which doesn't exists;", delegate];
		return NO;
	}
}

+(void) registerDelegate: (Class)delegate forFeature: (NSString *)feature
{
	MPOC_LOCK;
	NSMutableArray *delegs = [delegatesByFeature objectForKey: feature];
	if (!delegs)
	{
		delegs = [NSMutableArray new];
		[delegatesByFeature setObject: delegs forKey: feature];
		NSMutableArray *features = [featuresByDelegate objectForKey: delegate];
		if (!features)
		{
			features = [NSMutableArray new];
			[featuresByDelegate setObject: features forKey: delegate];
			[features release];
		}
		[features addObject: feature];
		[delegs release];
	}
	if (![delegs containsObject: delegate])
	{
		[delegs addObject: delegate];
		NSArray *objsbyfeature = [self getObjectsByFeature: feature];
		NSUInteger i, count = [objsbyfeature count];
		for (i=0; i<count; ++i)
		{
			[[objsbyfeature objectAtIndex: i] setLocalDelegate: delegate];
		}
		[gLog add: notice withFormat: @"MPObject: delegate \"%@\" added for feature \"%@\";", delegate, feature];
	}
	else
	{
		[gLog add: warning withFormat: @"MPObject: attempt to re-add delegate \"%@\" for feature \"%@\";", delegate, feature];
	}
	MPOC_UNLOCK;
}


+(void) registerDelegate: (Class)delegate forFeatures: (NSArray *)features
{
	NSUInteger i, count = [features count];
	for (i=0; i<count; ++i)
	{
		[self registerDelegate: delegate forFeature: [features objectAtIndex: i]];
	}
}

+(void) setUserInfo: (void *)userInfo forDelegateClass: (Class)delegate
{
	id wrapper;
	wrapper = [[MPUserInfoWrapper alloc] initWithUserInfo: userInfo];
	[delegateClassPerUserInfo setObject: wrapper forKey: delegate];
	[wrapper release];
}

+(void) removeDelegate: (Class)delegate forFeatures: (NSArray *)features
{
	NSUInteger i, count = [features count];
	for (i=0; i<count; ++i)
	{
		[self removeDelegate: delegate forFeature: [features objectAtIndex: i]];
	}
}

+(BOOL) removeDelegate: (Class)delegate forFeature: (NSString *)feature
{
	NSMutableArray *delegs;
	BOOL ret = NO;
	delegs = [delegatesByFeature objectForKey: feature];
	if ([delegs containsObject: delegate]) //would be false if delegs doesn't exist
	{
		NSArray *objsbyfeature;
		MPOC_LOCK;
		[delegs removeObject: delegate];
		[[featuresByDelegate objectForKey: delegate] removeObject: feature];

		objsbyfeature = [[self getObjectsByFeature: feature] copy];
		MPOC_UNLOCK;
		NSUInteger i, count = [objsbyfeature count];
		for (i=0; i<count; ++i)
		{
			[[objsbyfeature objectAtIndex: i] removeLocalDelegate: delegate];
		}
		[objsbyfeature release];
		[gLog add: notice withFormat: @"MPObject: delegate \"%@\" removed for feature \"%@\";", delegate, feature];
		ret = YES;
	}
	else
	{
		[gLog add: warning withFormat: @"MPObject: attempt to remove delegate \"%@\" for feature \"%@\" which doesn't exists",
		   	delegate, feature];
	}
	return ret;
}

+(void) unregisterDelegateFromAll: (Class)delegate
{
	MPOC_LOCK;
	if ([delegatesArray containsObject: delegate])
	{
		[self removeDelegate: delegate];
	}
	MPOC_UNLOCK;
	[self removeDelegate: delegate forFeatures: [[[featuresByDelegate objectForKey: delegate] copy] autorelease]];
}

-(NSMethodSignature *) methodSignatureForSelector: (SEL)selector
{
	if ([super respondsToSelector: selector])
	{
		return [super methodSignatureForSelector: selector];
	}
	else
	{
		NSMethodSignature *sig = nil;
		MPO_LOCK;
	
		id delegate;
		MPRemovalStableListStoredPosition oldPosition = [delegatesList storePosition];
		[delegatesList moveToTail];
		while ((delegate = [delegatesList prev]) != nil)
		{
			BOOL responds;
			MPO_TUNLOCK;
			responds = [delegate respondsToSelector: selector];
			MPO_TLOCK;
			if (responds)
			{
				MPO_TUNLOCK;
				sig = [delegate methodSignatureForSelector: selector];
				MPO_TLOCK;

				break;
			}
		}
		[delegatesList restorePosition: oldPosition];
		MPO_UNLOCK;
		return sig;
	}
}

-(void) forwardInvocation: (NSInvocation *)anInvocation
{
	SEL aSelector = [anInvocation selector];
	BOOL responded = NO;
	MPO_LOCK;

	id delegate;
	MPRemovalStableListStoredPosition oldPosition = [delegatesList storePosition];
	[delegatesList moveToTail];
	while ((delegate = [delegatesList prev]) != nil)
	{
		BOOL responds;
		MPO_TUNLOCK;
		responds = [delegate respondsToSelector: aSelector];
		MPO_TLOCK;
		if (responds)
		{
			[delegate retain];
			MPO_TUNLOCK;
			[anInvocation invokeWithTarget: delegate];
			MPO_TLOCK;

			[delegate release];
			responded = YES;
		}
	}
	[delegatesList restorePosition: oldPosition];
	MPO_UNLOCK;
	if (!responded)
	{
		[anInvocation invokeWithTarget: nil];
		[gLog add: warning withFormat: @"MPObject: no delegate of object \"%@\" to respond to selector: \"%s\";",
			self, sel_getName(aSelector)];
	}
}

-(BOOL) respondsToSelector: (SEL)aSelector
{
	BOOL ret=NO;
	MPO_LOCK;
	if ([super respondsToSelector: aSelector])
	{
		ret = YES;
	}
	else
	{
		id delegate;
		[delegatesList moveToHead];
		while ((delegate = [delegatesList next]) != nil)
		{
			MPO_TUNLOCK;
			if ([delegate respondsToSelector: aSelector])
			{
				ret = YES;
			}
			MPO_TLOCK;
			if (ret)
			{
				break;
			}
		}
	}
	MPO_UNLOCK;
	return ret;
}

+(NSArray *) getAllObjects
{
	return objectsArray;
}

+(NSArray *) getObjectsByFeature: (NSString *)name
{
	NSArray *objectsForFeature;
	MPOC_LOCK;
	objectsForFeature = [objectsByFeature objectForKey: name];
	if (!objectsForFeature)
	{
		objectsForFeature = [NSMutableArray new];
		[objectsByFeature setObject: objectsForFeature forKey: name];
		[objectsForFeature release];
	}
	MPOC_UNLOCK;
	return [NSArray arrayWithArray: objectsForFeature];
}

+(id<MPObject>) getObjectByName: (NSString *)name
{
	return [objectByName objectForKey: name];
}

+(id<MPObject>) getObjectByHandle: (NSNumber *)handle
{
	return [objectByHandle objectForKey: handle];
}

-(id) copy
{
	return [self copyWithZone: NULL];
}

-(id) copyWithName: (NSString *)newname
{
	return [self copyWithZone: NULL copyName: newname];
}

-(id) copyWithZone: (NSZone *)zone
{
	NSMutableString *nname;
	nname = [[NSMutableString alloc] initWithString: objectName];
	do
	{
		[nname appendString: @"_"];
	}
	while ([MPObject existsObjectWithName: nname]);
	id copied = [self copyWithZone: zone copyName: nname];
	[nname release];
	return copied;
}

-(id) copyWithZone: (NSZone *)zone copyName: (NSString*) newname;
{
	MPObject *newobj;
	MPO_LOCK;
	if ([MPObject existsObjectWithName: newname])
	{
		[gLog add: warning withFormat: @"<MPObject> Attempt to copy existing object \"%@\""
										"to zone \"%@\"",
			objectName, NSZoneName(zone)];
		return nil;
	
	}
	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: copying \"%@\" to zone \"%@\"; New name: \"%@\"",
		objectName, NSZoneName(zone), newname];
	#endif
	
	NSAutoreleasePool *pool;
	pool = [[NSAutoreleasePool alloc] init];

	newobj = [[MPObject allocWithZone: zone] initWithName: newname];

	NSEnumerator *enumer;
	NSDictionary *feat;
	feat = [self getAllFeatures];
	enumer = [feat keyEnumerator];

	NSString *str;
	while ( (str = [enumer nextObject]) != nil )
	{
		[newobj setFeature: str toValue: [feat objectForKey: str]];
	}

	[pool release];
	MPO_UNLOCK;
	return newobj;
}



-(void) encodeWithCoder: (NSCoder *)encoder
{
	MPO_LOCK;
	[encoder encodeObject:	objectName		forKey: @"MPObject_name"];
	[encoder encodeObject:	objectHandle	forKey: @"MPObject_handle"];
	[encoder encodeObject:	features		forKey: @"MPObject_features"];
	MPO_UNLOCK;
}

-(id) initWithCoder: (NSCoder *)decoder
{
	id<MPObject> curobj;
	MPO_LOCK;
	NSString *newName;
	NSDictionary *newFeatures;
	NSNumber *newHandle;
	
	newName		=	[decoder decodeObjectForKey:	@"MPObject_name"];
	newFeatures	=	[decoder decodeObjectForKey:	@"MPObject_features"];
	newHandle	=	[decoder decodeObjectForKey:	@"MPObject_handle"];

	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: decoding object: \"%@\"...", newName];
	#endif

	curobj = [self initWithName: newName withHandle: newHandle];

	if (handleCounter < [newHandle MPHANDLE_VALUE])
	{
		handleCounter = [newHandle MPHANDLE_VALUE];
	}

	NSEnumerator *enumer;
	enumer = [newFeatures keyEnumerator];

	NSString *obj;
	while ( (obj = [enumer nextObject]) != nil )
	{
		[curobj setFeature: [obj copy] toValue: [[newFeatures objectForKey: obj] copy]];
	}
	MPO_UNLOCK;
	return curobj;
}


-(NSString *) getName
{
	return [[objectName copy] autorelease];
}

-(NSNumber *) getHandle
{
	return [[objectHandle copy] autorelease];
}

-(NSDictionary *) getAllFeatures
{
	return [[features copy] autorelease];
}

-(id<MPVariant>) getFeatureData: (NSString *)name
{
	id val;
	MPO_LOCK;
	val = [[[features objectForKey: name] copy] autorelease];
	if (!val)
	{
		val = [MPVariant variantWithString: @""];
	}
	MPO_UNLOCK;
	return val;
}

-(BOOL) hasFeature: (NSString *)name
{
	return ([features objectForKey: name] != nil);
}

-(void) setFeature: (NSString *)name
{
	[self setFeature: name toValue: [MPVariant variant]];
}

-(void) setFeature: (NSString *)name toValue: (id<MPVariant>)data
{
	[self setFeature: name toValue: data userInfo: nil];
}

-(void) setFeature: (NSString *)name toValue: (id<MPVariant>)data userInfo: (MPCDictionaryRepresentable *)userInfo
{
	MPO_LOCK;
	[userInfo retain];
	NSMutableArray *featuresArray;
	MPOC_LOCK;
	featuresArray = [objectsByFeature objectForKey: name];
	if (!featuresArray)
	{
		featuresArray = [[NSMutableArray alloc] init];
		[objectsByFeature setObject: featuresArray forKey: name];
	}
	if (![featuresArray containsObject: self])
	{
		[featuresArray addObject: self];
		++internalRetainCount;

		//assign delegate for this feature
		NSArray *dels = [delegatesByFeature objectForKey: name];
		NSUInteger i, count=[dels count];
		for (i=0; i<count; ++i)
		{
			[self setLocalDelegate: [dels objectAtIndex: i]];
		}

		#ifdef MPOBJECT_DETAILLOGGING
		[gLog add: info withFormat: @"MPObject: \"%@\": Feature \"%@\" added", objectName, name];
		#endif
	}
	MPOC_UNLOCK;
	id<MPVariant> newData = [data copy];
	
	MPRemovalStableListStoredPosition storedPos = [delegatesList storePosition];
	id delegate;
	[delegatesList moveToHead];
	while ((delegate = [delegatesList next]) != nil)
	{
		if ([delegate respondsToSelector: @selector(setFeature:toValue:userInfo:)])
		{
			[delegate setFeature: name toValue: data userInfo: userInfo];
		}
		else if ([delegate respondsToSelector: @selector(setFeature:toValue:)])
		{
			[delegate setFeature: name toValue: data];
		}
	}
	[delegatesList restorePosition: storedPos];

	[features setObject: newData forKey: name];

	[newData release]; //give ownership to features
	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: \"%@\": Feature \"%@\" set to \"%@\" with params: \"%@\"",
		objectName, name, [data stringValue], userInfo];
	#endif
	[userInfo release];
	MPO_UNLOCK;
}

-(void) removeFeature: (NSString *)name
{
	[self removeFeature: name userInfo: nil];
}

-(void) removeFeature: (NSString *)name userInfo: (MPCDictionaryRepresentable *)userInfo
{
	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: \"%@\": Removing feature \"%@\" with user info: \"%@\"",
																			objectName, name, userInfo];
	#endif
	MPO_LOCK;
	[userInfo retain];
	MPVariant *value;
	value = [features objectForKey: name];
	if (value)
	{
		[features removeObjectForKey: name];
		--internalRetainCount;

		NSUInteger i, count;

		MPRemovalStableListStoredPosition storedPos = [delegatesList storePosition];
		[delegatesList moveToHead];
		id delegate;
		while ((delegate = [delegatesList next]) != nil)
		{
			if ([delegate respondsToSelector: @selector(removeFeature:userInfo:)])
			{
				[delegate removeFeature: name userInfo: userInfo];
			}
			else if ([delegate respondsToSelector: @selector(removeFeature:)])
			{
				[delegate removeFeature: name];
			}
		}
		[delegatesList restorePosition: storedPos];
		
		NSMutableArray *dels;

		MPOC_LOCK;
		dels = [delegatesByFeature objectForKey: name];
		if ([dels containsObject: self])
		{
			--internalRetainCount;
			[dels removeObject: self];
		}
		
		count=[dels count];
		for (i=0; i<count; ++i)
		{
			[self removeLocalDelegate: [dels objectAtIndex: i]];
		}
		MPOC_UNLOCK;
		
		#ifdef MPOBJECT_DETAILLOGGING
		[gLog add: info withFormat: @"MPObject: \"%@\": Feature \"%@\" removed with user info: \"%@\"",
																				objectName, name, userInfo];
		#endif
		
	}
	[userInfo release];
	MPO_UNLOCK;

}

-(NSUInteger) hash
{
	return [objectHandle hash];
}

-(BOOL) isEqual: (id)anObject
{
	if ([anObject isKindOfClass: [MPObject class]])
	{
		return ((MPObject *)anObject)->objectHandle == objectHandle;
	}
	return NO;
}

-(NSString *) description
{
	return [NSString stringWithFormat: @"%@ [%@]", objectName, objectHandle];
}

-(oneway void) release
{
	MPO_LOCK;
	MPOC_LOCK;
	NSAssert2(removed || ([self retainCount]-1 >= internalRetainCount), @"internalRetainCount (%u) is more than [self retainCount]-1 (%u)",
									internalRetainCount, [self retainCount]-1);
	if (!removed && ([self retainCount]-1 == internalRetainCount))	//[self retainCount] is still not actually decreased
																	//(but would be at the end of this method)
																	//so we count it as [self retainCount]-1
	{
		#ifdef MPOBJECT_DETAILLOGGING
		[gLog add: info withFormat: @"MPObject: removing object \"%@\"...", objectName];
		#endif
		removed = YES;

		MPDictionary *params = [[MPDictionary alloc] initWithObjectsAndKeys:
			objectName,								MPParamObjectName,
			[handleMapper getObject: objectHandle],	MPParamObjectHandle,
			nil];
		MPPostNotification(MPObjectRemovedMessage, params);
		[params release];

		[objectsArray removeObject: self];	
		[objectByName removeObjectForKey: objectName];
		[objectByHandle removeObjectForKey: objectHandle];
		internalRetainCount -= 3;

		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		NSEnumerator *enumer = [[features allKeys] objectEnumerator];
		id featureKey;
		while ((featureKey = [enumer nextObject]) != nil)
		{
			[self removeFeature: featureKey];
		}
		[pool release];
	}
	MPOC_UNLOCK;
	MPO_UNLOCK;	
	[super release];
}

-(void) clean
{
	MPO_LOCK;
	NSDictionary *featuresToRemove = [self getAllFeatures];
	NSEnumerator *enumer;
	enumer = [featuresToRemove keyEnumerator];
	NSString *featureName;
	while ( (featureName = [enumer nextObject]) != nil )
	{
		[self removeFeature: featureName];
	}
	MPO_UNLOCK;
}

-(void) dealloc
{
	#ifdef MPOBJECT_DETAILLOGGING
	NSString *name = [objectName copy];
	#endif

	[objectName release];
	[objectHandle release];
	[features release];
	[delegatesList release];
	[accessMutex release];
	[countPerDelegate release];
	[super dealloc];

	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: object \"%@\" deallocated", name];
	[name release];
	#endif
}

-(void) lock
{
	#ifdef MPOBJECT_ENABLESYNCHRONISATION
	[accessMutex lock];
	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: object \"%@\" locked", objectName];
	#endif
	#endif
}

-(void) unlock
{
	#ifdef MPOBJECT_ENABLESYNCHRONISATION
	[accessMutex unlock];
	#ifdef MPOBJECT_DETAILLOGGING
	[gLog add: info withFormat: @"MPObject: object \"%@\" unlocked", objectName];
	#endif
	#endif
}

@end

