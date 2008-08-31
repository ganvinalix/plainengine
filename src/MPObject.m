#import <MPObject.h>

MPObject *rootObject;
unsigned defaultNameCount;
NSMutableDictionary *allObjects;
NSMutableDictionary *featuresMap;

@implementation MPBaseObject

@end

@implementation MPObject

+(void) load
{
	rootObject = [[MPObject alloc] initWithName: @"*" rootObject: nil];
	rootObject->root = rootObject;

	allObjects = [[NSMutableDictionary alloc] init];
	[allObjects setObject: rootObject forKey: @"*"];

	featuresMap = [[NSMutableDictionary alloc] init];

	defaultNameCount = 0;
}

+(id<MPObject>) getObjectByName: (NSString *)name
{
	return [allObjects objectForKey: name];
}

+(NSArray *) getObjectsByFeature: (NSString *)name
{
	return [[featuresMap objectForKey: name] copy];
}

-init
{
	return [self initWithName: [NSString stringWithFormat: @"default%d", defaultNameCount++]];
}

-initWithName: (NSString *)newName
{
	return [self initWithName: newName rootObject: rootObject];
}

-initWithName: (NSString *)newName rootObject: (MPObject *)aRootObject
{
	return [self initWithName: newName rootObject: rootObject manuallyDeletable: YES];
}

-initWithName: (NSString *)newName rootObject: (MPObject *)aRootObject manuallyDeletable: (BOOL)manuallyDeletable
{
	MPObject *obj;
	obj = [allObjects objectForKey: newName];
	if (obj)
	{
		[self release];
		return obj;
	}
	[allObjects setObject: self forKey: newName];
	deletable = manuallyDeletable;
	objectName = [newName copy];
	if (aRootObject)
	{
		[aRootObject->subObjects addObject: self];
	}
	subObjects = [[NSMutableArray alloc] init];
	features = [[NSMutableDictionary alloc] init];
	root = aRootObject;
	return self;
}

-(id<MPObject>) getParent
{
	return root;
}

-(NSArray *) getSubObjects
{
	return [subObjects copy];
}

-(void) setFeature: (NSString *)name data: (MPFeatureData *)data
{
	NSMutableArray *featuresArray = [featuresMap objectForKey: name];
	if (!featuresArray)
	{
		featuresArray = [[NSMutableArray alloc] init];
		[featuresMap setObject: featuresArray forKey: name];
	}
	if (![featuresArray containsObject: self])
	{
		[featuresArray addObject: self];
	}
	[features setObject: data forKey: name];
}

-(void) removeFeature: (NSString *)name
{
	[features removeObjectForKey: name];
	[[featuresMap objectForKey: name] removeObject: self];
}

-(MPFeatureData *) getFeatureData: (NSString *)name
{
	return [features objectForKey: name];
}

-(BOOL) remove
{
	if (!deletable)
	{
		return NO;
	}
	[root->subObjects addObjectsFromArray: subObjects];
	[subObjects removeAllObjects];
	return YES;
}

-(BOOL) removeWholeNode
{
	if (!deletable)
	{
		return NO;
	}
	[self release];
	return YES;
}

-(void) dealloc
{	
	NSEnumerator *enumer;
	enumer = [subObjects objectEnumerator];
	[allObjects removeObjectForKey: objectName];

	MPObject *thr;
	while ( (thr = [enumer nextObject]) != nil )
	{
		[thr release];
	}

	[subObjects release];
	[features release];
	[super dealloc];
}

@end

