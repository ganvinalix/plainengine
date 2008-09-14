#import <Foundation/Foundation.h>
#import <MPBaseObject.h>
#import <MPObject.p>

/** MPObject interface */
@interface MPObject : MPBaseObject <MPObject> 
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

