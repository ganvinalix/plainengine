#import <Foundation/Foundation.h>
#import <MPBaseObject.h>

/** Feature data type */
typedef NSNumber MPFeatureData;

/** MPObject protocol */
@protocol MPObject <NSObject>

/** Returns array of all registered MPObject*'s */
+(NSArray *) getAllObjects;
/** Returns root object (equal to [MPObject getObjectByName: @"*"]), but bit more convinient */
+(id<MPObject>) getRootObject;
/** Returns object with given name */
+(id<MPObject>) getObjectByName: (NSString *)name;
/** Returns array of all objects which have feature with given name */
+(NSArray *) getObjectsByFeature: (NSString *)name;

/** Saves object to file with given name */
+(void) saveToFile: (NSString *)fileName;
/** Loads object from file with given name */
+(void) loadFromFile: (NSString *)fileName;

/** Removes all objects, then recreates root object */
+(void) removeAllObjects;

/** Return parent of current object */
-(id<MPObject>) getParent;
/** Returns all objects which has reciever as their parent */
-(NSArray *) getSubObjects;

/** Moves object to reciever subobjects tree */
-(void) moveSubObject: (id<MPObject>)object;

/** Returns name of current object */
-(NSString *) getName;

/** Returns copy of reciever with name ###_ where ### is reciever name */
-(id) copy;

/** Removes this object if able; its children becomes children of reciever's parent */
-(BOOL) remove;
/** Removes this object; if succeed, removes its children (always)*/
-(BOOL) removeWholeNode;

@end

/** MPObject interface */
@interface MPObject : MPBaseObject <MPObject>/*< NSCopying, NSMutableCopying, NSCoding > */
	// representation in world ( id<MPBaseObject> repr, access functions )
	// composite stuff (iterators, children managment, owner managment)
		///!!! is NSMutableArray NSutableCopying???
	// NSCopying, MutableCopying
	// NSCoding
	// Features stuff ( add/remove, (MPFeature*)getFeatureBy[Id/Name], (NSSet) getFeatures, isA(feature[id/name]) )
{
	MPObject *root;
	NSString *objectName;
	NSMutableArray *subObjects;
	NSMutableDictionary *features;
	BOOL deletable;
}

+(void) load;

/** Inits new object with name "default#", where # - unique unsigned value, main root object as parent and manually deletable */
-init;
/** Inits new object with name newName, main root object as parent and manually deletable */
-initWithName: (NSString *)newName;
/** Inits new object with name newName, rootObject as parent and manually deletable */
-initWithName: (NSString *)newName rootObject: (MPObject *)aRootObject;
/** Inits new object with name newName, rootObject as parent and manually deletable if manuallyDeletable is YES */
-initWithName: (NSString *)newName rootObject: (MPObject *)aRootObject manuallyDeletable: (BOOL)manuallyDeletable;

/** Returns dictionary of all reciever features with format (NSString(feature name), MPFeatureData(feature data)) */
-(NSDictionary *) getAllFeatures;
/** Creates feature if it isn't exist; else replaces it */
-(void) setFeature: (NSString *)name data: (MPFeatureData *)data;
/** Remove feature if exists; else does nothing */
-(void) removeFeature: (NSString *)name;
/** Gets data of feature with given name */
-(MPFeatureData *) getFeatureData: (NSString *)name;

/** Prepares object for deleting; only for internal use */
-(void) unregister;
/** Deallocates reciever */
-(void) dealloc;

@end

/** Prints object tree to gLog as info */
void printObjectTree(id<MPObject> root);

