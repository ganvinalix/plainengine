#import <MPObject.h>
#import <common.h>

MPObject *rootObject;
unsigned defaultNameCount;
NSMutableDictionary *allObjects;
NSMutableDictionary *featuresMap;
NSMutableArray *orderedObjects;

void printObjectTreeReal(id<MPObject> root, unsigned step)
{
	NSMutableString *line;
	line = [[NSMutableString alloc] init];
	unsigned i;
	for (i=0; i<step; ++i)
	{
		[line appendString: @"-"];
	}

	[line appendString: [root getName]];
	[gLog add: info withFormat: line];
	[line release];

	NSEnumerator *enumer;
	enumer = [[root getSubObjects] objectEnumerator];
	id<MPObject> obj;
	while ( (obj = [enumer nextObject]) != nil )
	{
		printObjectTreeReal(obj, step+1);
	}
}

void printObjectTree(id<MPObject> root)
{
	printObjectTreeReal(root, 0);
}

@implementation MPBaseObject

@end

@implementation MPObject

+(void) load
{
	allObjects = [[NSMutableDictionary alloc] init];
	featuresMap = [[NSMutableDictionary alloc] init];
	orderedObjects = [[NSMutableArray alloc] init];

	rootObject = [[MPObject alloc] initWithName: @"*" rootObject: nil manuallyDeletable: NO];
	rootObject->root = rootObject;

	[allObjects setObject: rootObject forKey: @"*"];

	defaultNameCount = 0;
}

+(NSArray *) getAllObjects
{
	return [orderedObjects copy];
}

+(id<MPObject>) getObjectByName: (NSString *)name
{
	return [allObjects objectForKey: name];
}

+(id<MPObject>) getRootObject
{
	return [MPObject getObjectByName: @"*"];
}

+(NSArray *) getObjectsByFeature: (NSString *)name
{
	return [[featuresMap objectForKey: name] copy];
}

-(NSString *) getName
{
	return [[objectName copy] autorelease];
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
	return [self initWithName: newName rootObject: aRootObject manuallyDeletable: YES];
}

-initWithName: (NSString *)newName rootObject: (MPObject *)aRootObject manuallyDeletable: (BOOL)manuallyDeletable
{
	//NSLog(@"init:");
	//NSLog(newName);
	MPObject *obj;
	obj = [allObjects objectForKey: newName];
	if (obj)
	{
		[self release];
		return obj;
	}
	[allObjects setObject: self forKey: newName];
	[orderedObjects addObject: self];
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

-(void) encodeWithCoder: (NSCoder *)encoder
{
	//NSString *str = ([NSString stringWithFormat: @"encoded: %@;", [self getName]]);
	//MP_LOG(str);
	[encoder encodeConditionalObject:	[root getName]		forKey: @"MPObject_root"];
	[encoder encodeObject:			[self getName]		forKey: @"MPObject_name"];
	[encoder encodeObject:			[self getAllFeatures]	forKey: @"MPObject_features"];
	[encoder encodeBool:			deletable		forKey: @"MPObject_deletable"];
}

-(id) initWithCoder: (NSCoder *)decoder
{
	NSString *newRoot, *newName;
	NSDictionary *newFeatures;
	BOOL del;
	
	del = [decoder decodeBoolForKey: @"MPObject_deletable"];
	newRoot = [decoder decodeObjectForKey: @"MPObject_root"];
	newName = [[decoder decodeObjectForKey: @"MPObject_name"] retain];
	newFeatures = [[decoder decodeObjectForKey: @"MPObject_features"] retain];
	
	if (!([newRoot compare: newName] == NSOrderedSame))
	{
		[self initWithName: newName rootObject: [MPObject getObjectByName: newRoot] manuallyDeletable: del];
	}

	NSEnumerator *enumer;
	enumer = [newFeatures keyEnumerator];

	NSString *obj;
	while ( (obj = [enumer nextObject]) != nil )
	{
		[self setFeature: [obj copy] data: [[newFeatures objectForKey: obj] copy]];
		//[gLog add: info withFormat: @"feature added: %@ - %@", obj, [newFeatures objectForKey: obj]];
	}
	//MP_LOG(@"______");
	return self;
}

-(id<MPObject>) getParent
{
	return root;
}

-(NSArray *) getSubObjects
{
	return [[subObjects copy] autorelease];
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

-(NSDictionary *) getAllFeatures
{
	return [[features copy] autorelease];
}
  
-(id) copyWithZone: (NSZone *)zone
{
	NSMutableString *newname;
	newname = [NSMutableString stringWithString: [self getName]];
	do
	{
		[newname appendString: @"_"];
	}
	while ([MPObject getObjectByName: newname]);
	MPObject *newobj;
	newobj = [[MPObject allocWithZone: zone] initWithName: newname
				     rootObject: [self getParent]
			      manuallyDeletable: deletable];

	NSEnumerator *enumer;
	NSDictionary *feat;
	feat = [self getAllFeatures];
	enumer = [feat keyEnumerator];

	NSString *str;
	while ( (str = [enumer nextObject]) != nil )
	{
		[newobj setFeature: str data: [feat objectForKey: str]];
	}

	enumer = [[self getSubObjects] objectEnumerator];
	MPObject *sub;
	while ( (sub = [enumer nextObject]) != nil )
	{
		[newobj moveSubObject: [sub copy]];
	}
	return newobj;
}

-(void) moveSubObject: (id<MPObject>)object
{
	[subObjects addObject: object];
	MPObject *obj;
	obj = [object getParent];
	[obj->subObjects removeObject: object];
	((MPObject *)object)->root = self;
}

+(void) saveToFile: (NSString *)fileName
{
	/*
	MP_LOG(@"|---");
	NSEnumerator *enumer;
	enumer = [allObjects objectEnumerator];
	MPObject *obj;
	
	while ( (obj = [enumer nextObject]) != nil )
	{
		MP_LOG([obj getName]);
	}

	MP_LOG(@"--|");
	*/	
	//[NSKeyedArchiver archiveRootObject: allObjects toFile: fileName];
	[NSKeyedArchiver archiveRootObject: orderedObjects toFile: fileName];
}

+(void) loadFromFile: (NSString *)fileName
{
	[self removeAllObjects];
	[NSKeyedUnarchiver unarchiveObjectWithFile: fileName];
}

+(void) removeAllObjects
{
	//reset
	rootObject->deletable = YES;
	[rootObject removeWholeNode];

	[featuresMap release];
	[allObjects release];
	[orderedObjects release];
	[MPObject load];
}

-(BOOL) remove
{
	if (!deletable)
	{
		return NO;
	}
	[root->subObjects addObjectsFromArray: subObjects];
	[subObjects removeAllObjects];
	[self unregister];
	return YES;
}

-(BOOL) removeWholeNode
{
	if (!deletable)
	{
		return NO;
	}
	[self unregister];
	return YES;
}

-(void) unregister 
{
	[allObjects removeObjectForKey: objectName];
	[orderedObjects removeObject: self];
	NSEnumerator *enumer;
	enumer = [features keyEnumerator];

	NSString *obj;
	while ( (obj = [enumer nextObject]) != nil )
	{
		[self removeFeature: obj];
	}
	[root->subObjects removeObject: self];
	[self release];
}

-(void) dealloc
{	
	NSEnumerator *enumer;
	enumer = [subObjects objectEnumerator];

	MPObject *obj;
	while ( (obj = [enumer nextObject]) != nil )
	{
		[obj release];
	}
		
	enumer = [features keyEnumerator];

	NSString *featureName;
	while ( (featureName = [enumer nextObject]) != nil )
	{
		[self removeFeature: featureName];
	}
	
	[subObjects release];
	[features release];
	[super dealloc];
}

@end

