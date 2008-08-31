#import <Foundation/Foundation.h>
#import <MPBaseObject.h>

typedef NSValue MPFeatureData;

@protocol MPObject

+(id<MPObject>) getObjectByName: (NSString *)name;
+(NSArray *) getObjectsByFeature: (NSString *)name;

-(id<MPObject>) getParent;
-(NSArray *) getSubObjects;

-(BOOL) remove;
-(BOOL) removeWholeNode;

@end

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

-initWithName: (NSString *)newName;
-initWithName: (NSString *)newName rootObject: (MPObject *)aRootObject;
-initWithName: (NSString *)newName rootObject: (MPObject *)aRootObject manuallyDeletable: (BOOL)manuallyDeletable;

-(void) setFeature: (NSString *)name data: (MPFeatureData *)data;
-(void) removeFeature: (NSString *)name;
-(MPFeatureData *) getFeatureData: (NSString *)name;

-init;
-(void) dealloc;

@end
