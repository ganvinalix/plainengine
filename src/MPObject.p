#import <Foundation/Foundation.h>
#import <MPVariant.p>
#import <MPDictionary.p>

/** Object handle type */
typedef long long MPHandle;

/** Name of NSNumber and NSString method, which returns MPHandle */
#define MPHANDLE_VALUE longLongValue

/** Name of NSNumber initialize method for MPHandle */
#define INIT_WITH_MPHANDLE initWithLongLong

@protocol MPObject <NSObject, NSCoding, NSCopying>

/** Is equal to [[MPObject alloc] initWithName: name] */
+newObjectWithName: (NSString *)name;

/** Adds delegate class to object system;
 *  All objects including existing onew would have an instance of this delegate
 *  (delegate is created by [delegate newDelegateWithObject:] (with object itself in param) if possible,
 *  otherwise created by [delegate new]);
 *  ------------------------------------------------------------------
 *  WARNING: Do not retain object recieved by 'newDelegateWithObject:'
 *  ------------------------------------------------------------------
 *  All messages that object can't handle would be redirected to this delegates in REVERSE registering order;
 *  Return value would be the last returned one (with regard to reverse order);
 *  If this delegate class (not subclass/root class) is already registered, does nothing
 *  */
+(void) registerDelegate: (Class)delegate;
/** Unregisters delegate if there is one; Removes all local instances if delegate in all existing objects;
  * Returns NO if delegate was not found */
+(BOOL) removeDelegate: (Class)delegate;

/** Registers delegate class for single feature.
  * It is guaranteed that all objects with given feature would have such delegate
  * And objects without this feature wouldn't
  * (of course, if this delegate is not contained by this object in another way, for example by another feature)
  * (look registerDelegate for description of delegates concept) */
+(void) registerDelegate: (Class)delegate forFeature: (NSString *)feature;

/** Registers delegate class for every of given feature names array element */
+(void) registerDelegate: (Class)delegate forFeatures: (NSArray *)features;

/** Unregisters delegate for given feature, discarding registerDelegate:byFeature effect
  * (but not the registerDelegate: one)
  * Returns NO if delegate was not found*/
+(BOOL) removeDelegate: (Class)delegate forFeature: (NSString *)feature;

/** Unregisters delegate class for every of given feature names array element */
+(void) removeDelegate: (Class)delegate forFeatures: (NSArray *)features;

/** Removes every instance if delegate from all objects */
+(void) unregisterDelegateFromAll: (Class)delegate;

/** Returns array of all registered MPObjects */
+(NSArray *) getAllObjects;

/** Returns array of all objects which have feature with given name */
+(NSArray *) getObjectsByFeature: (NSString *)name;
/** Returns object with given name or nil if isn't found */
+(id<MPObject>) getObjectByName: (NSString *)name;
/** Returns object with given handle or nil if isn't found */
+(id<MPObject>) getObjectByHandle: (NSNumber *)handle;

/** Creates object with given name and posts message 'MPObjectCreatedMessage' with parametets:
 * - objectName - name of new object
 * - objectHandle - handle of new object */
-initWithName: (NSString *)aName;

/** Returns copy of reciever as 'copyWithZone:zone' does and allocates it in default zone; */
-(id) copy;
/** Returns copy of reciever as 'copyWithZone:zone:copyName' does and allocates it in default zone; */
-(id) copyWithName: (NSString *)newname;
/** Returns copy of reciever with name ###_ where ### is reciever name and allocates it in zone; if already exists, creates copy with name ###__ and etc */
-(id) copyWithZone: (NSZone *)zone;
/** Returns copy of reciever with name 'newname' and allocates it in zone; if already exists, returns nil */
-(id) copyWithZone: (NSZone *)zone copyName: (NSString*) newname;

/** Returns name of current object */
-(NSString *) getName;
/** Returns handle of reciever; handle is of type 'MPHandle' and is unique; root handle is 0 */
-(NSNumber *) getHandle;

/** Returns dictionary of all reciever features with format (NSString(feature name), MPVariant(feature data)) */
-(NSDictionary *) getAllFeatures;
/** Gets data of feature with given name */
-(id<MPVariant>) getFeatureData: (NSString *)name;

/** Returns YES if has given feature */
-(BOOL) hasFeature: (NSString *)name;

/** Creates feature without value if it isn't exist and returns YES; else replaces it and returns NO;
 *  'setFeature:' is fully equal to 'setFeature:toValue:' with empty value */
-(void) setFeature: (NSString *)name;

/** Creates feature if it isn't exist and returns YES; else replaces it and returns NO;
 *  All delegates recieve 'setFeature:toValue:userInfo:' message if possible;
 *  If delegate don't responds to this selector but responds to 'setFeature:toValue:',
 *  it recieves 'setFeature:toValue:' instead */
-(void) setFeature: (NSString *)name toValue: (id<MPVariant>)data;

/** Creates feature if it isn't exist and returns YES; else replaces it and returns NO;
 *  All delegates recieve 'setFeature:toValue:userInfo:' message if possible;
 *  If delegate don't responds to this selector but responds to 'setFeature:toValue:',
 *  it recieves 'setFeature:toValue:' instead */
-(void) setFeature: (NSString *)name toValue: (id<MPVariant>)data userInfo: (MPCDictionaryRepresentable *)userInfo;

/** Removes feature if exists and returns YES; else returns NO;
 *  This method is called on object removal for each feature. */
-(void) removeFeature: (NSString *)name;

/** Removes feature if exists and returns YES; else returns NO;
 *  This method is called on object removal for each feature. */
-(void) removeFeature: (NSString *)name userInfo: (MPCDictionaryRepresentable *)userInfo;

/** Locks object to avoid changing in another thread  (Must be unlocked!) */
-(void) lock;
/** Unlocks object */
-(void) unlock;

/** Removes all features from this object */
-(void) clean;

@end

