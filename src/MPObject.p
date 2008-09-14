#import <Foundation/Foundation.h>
#import <MPBaseObject.p>

/** Feature data type */
typedef NSNumber MPFeatureData;

/** MPObject protocol */
@protocol MPObject <NSObject, NSCopying, NSCoding, MPBaseObject>

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
-(id) copyWithZone: (NSZone *)zone;

/** Removes this object if able; its children becomes children of reciever's parent */
-(BOOL) remove;
/** Removes this object; if succeed, removes its children (always)*/
-(BOOL) removeWholeNode;

@end

