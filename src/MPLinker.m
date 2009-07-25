#import <MPLinker.h>
#import <MPUtility.h>
#import <core_constants.h>

@implementation MPSubjectDescription

- (void) setSubjectName: (NSString *)sName
		   subjectAlias: (NSString *)sAlias
			 moduleName: (NSString *)mName
			   threadId: (NSUInteger)tId
	   parametersString: (NSString *)par;
{
	threadId = tId;
	id old = nil;

	old = subjectName;
	subjectName = [sName copy];
	[old release];

	old = subjectAlias;
	subjectAlias = [sAlias copy];
	[old release];

	old = moduleName;
	moduleName = [mName copy];
	[old release];
	
	old = params;
	params = [par copy];
	[old release];
}

#define CHECK_THAT_STRING(x) \
	NSAssert( [x isKindOfClass: [NSString class]], @"Invalid plist structure!");
- initWithDictionary: (NSDictionary *)aDictonary
{
	if(!aDictonary)
		return nil;

	[super init];

	subjectName = nil;
	subjectAlias = nil;
	moduleName = nil;
	params = nil;
	threadId = 0;
	
	CHECK_THAT_STRING( [aDictonary objectForKey: MPSubjectNameKey] );
	CHECK_THAT_STRING( [aDictonary objectForKey: MPSubjectModuleNameKey] );

	NSMutableString *alias = [[aDictonary objectForKey: MPSubjectAliasKey] mutableCopy];
	if( !alias || [alias isEqualToString: @""] )
	{
		[alias release];
		alias = [[aDictonary objectForKey: MPSubjectNameKey] copy];
	}
	
	[self setSubjectName: [aDictonary objectForKey: MPSubjectNameKey]
			subjectAlias: alias
			  moduleName: [aDictonary objectForKey: MPSubjectModuleNameKey]
				threadId: [[aDictonary objectForKey: MPSubjectThreadIdKey] intValue]
		parametersString: [aDictonary objectForKey: MPSubjectParameterKey]];

	return self;
}
#undef CHECK_THAT_STRING

- initWithSubjectName: (NSString *)sName
		 subjectAlias: (NSString *)sAlias
		   moduleName: (NSString *)mName
			 threadId: (NSUInteger)tId
	 parametersString: (NSString *)par
{
	[super init];

	subjectName = nil;
	subjectAlias = nil;
	moduleName = nil;
	params = nil;
	threadId = 0;

	[self setSubjectName: sName
			subjectAlias: sAlias
			  moduleName: mName
				threadId: tId
		parametersString: par];

	return self;
}
- init
{
	return [self initWithSubjectName: @"Nothing"
						subjectAlias: @"Nothing"
						  moduleName: @"Nothing.ext"
							threadId: 0
					parametersString: @""];
}
- (void) dealloc
{
	[self setSubjectName: nil subjectAlias: nil moduleName: nil threadId: 0 parametersString: nil];
	[super dealloc];
}

- (NSString *) getSubjectName
{
	return [[subjectName copy] autorelease];
}
- (NSString *) getSubjectAlias
{
	return [[subjectAlias copy] autorelease];
}
- (NSString *) getModuleName
{
	return [[moduleName copy] autorelease];
}
- (NSString *) getParametersString
{
	return [[params copy] autorelease];
}
- (NSUInteger) getThreadId
{
	return threadId;
}
- (NSString *) description
{
	NSString *str = [NSString stringWithFormat: @"Name: %@\t Alias: %@\t Module: %@\t Thread: %d\t Params: %@",
												subjectName, subjectAlias, moduleName, threadId, params];

	return str;
}
@end

NSArray *MPBuildDescriptionsFromPlist(NSDictionary *plist)
{
	id subjects = [plist objectForKey: @"Subjects"];
	if(subjects)
		NSCAssert( [subjects isKindOfClass: [NSArray class]], @"Invalid plist structure!");

	id enumer = [subjects objectEnumerator], obj = nil;
	NSUInteger i = 0;

	NSMutableArray *result = [NSMutableArray array];
	MPSubjectDescription *desc = nil;
	while( (obj = [enumer nextObject]) != nil )
	{
		++i;

		if( ![obj isKindOfClass: [NSDictionary class]] )
		{
			[gLog add: warning withFormat: @"Subject description #%d isn't a dictionary!"];
			continue;
		}

		desc = [[MPSubjectDescription alloc] initWithDictionary: obj];
		[gLog add: notice withFormat: @"%@", [desc description]];
		[result addObject: desc];
		[desc release];
	}

	return result;
}

NSArray *MPParseLinkerConfig(NSString *config)
{
	NSArray *strings = [config componentsSeparatedByString: MP_EOL];
	NSMutableArray *result = [NSMutableArray new];

	NSUInteger i, count = [strings count];
	NSMutableString *subjectDescription, *subjectParams;
	subjectDescription = [NSMutableString string];
	subjectParams = [NSMutableString string];
	for (i=0; i<count; ++i)
	{
		NSMutableString *configString = [[strings objectAtIndex: i] mutableCopy];
		stringTrimLeft(configString);
		if ([configString isEqualToString: @""])
		{
			continue;
		}
		if ([configString characterAtIndex: 0]=='#')
		{
			continue;
		}
		separateString(configString, subjectDescription, subjectParams, @";");
		NSArray *descrParams = [subjectDescription componentsSeparatedByString: @":"];
		if ([descrParams count] != 3)
		{
			[gLog add: warning withFormat: @"MPLinker: Invalid initialization string on line %u", i+1];
			continue;
		}
		NSMutableString *subjName, *subjAlias;
		subjName = [NSMutableString string];
		subjAlias = [NSMutableString string];
		separateString([descrParams objectAtIndex: 1], subjName, subjAlias, @"=");
		if ([subjAlias isEqualToString: @""])
		{
			[subjAlias setString: subjName];
		}
		MPSubjectDescription *desc = [[MPSubjectDescription alloc]
				   initWithSubjectName: subjName
				   subjectAlias: subjAlias
				   moduleName: [descrParams objectAtIndex: 0]
				   threadId: [[descrParams objectAtIndex: 2] intValue]
				   parametersString: subjectParams];
				
		[result addObject: desc];
		[desc release];
		//moduleName:subjectName:threadNo;params 
	}

	return [result autorelease];
}

id MPLinkModules(NSArray *descriptions, MPSubjectManager *subjMan)
{
	if( (descriptions == nil) || (subjMan == nil) || ([descriptions count] < 1) ) 
	{
		[gLog add: error withFormat: @"MPLinkModules: invalid arguments"];
		return nil;
	}

	[descriptions retain];
	[subjMan retain];

	NSMutableDictionary *modules = [NSMutableDictionary dictionaryWithCapacity: 20];
	MPModule *module = nil;
	Class currentSubjectClass = nil;
	MPSubjectDescription *currentDesc = nil;

	NSEnumerator *descEnumerator = [descriptions objectEnumerator];
	while ( (currentDesc = [descEnumerator nextObject]) != nil )
	{
		if( ![currentDesc isKindOfClass: [MPSubjectDescription class]] )
		{
			[gLog add: warning withFormat: @"There is non description object in array of MPSubjectDescription"];
			continue;
		}

		// loading module if need
		if( (module = [modules objectForKey: [currentDesc getModuleName]]) == nil )
		{
			module = [MPModule module];
			if( ![module loadLibraryWithName: [currentDesc getModuleName]] )
			{
				[gLog add: warning withFormat: @"MPLinker: Could not loac the module with name [%@]", [currentDesc getModuleName]];
				continue;
			}
			[modules setObject: module forKey: [currentDesc getModuleName]];
		}

		// try to set up a next subject
		currentSubjectClass = objc_lookUpClass( [[currentDesc getSubjectName] UTF8String] );
		if( currentSubjectClass == nil ) 
		{
			[gLog add: warning withFormat: @"MPLinker: Class [%@] does not exist", [currentDesc getSubjectName]];
			continue;
		}
		if( ![currentSubjectClass conformsToProtocol: @protocol(MPSubject)] )
		{
			[gLog add: warning withFormat: @"MPLinker: Class [%@] does not conform to protocol MPSubject", currentSubjectClass];
			continue;
		}

		NSAutoreleasePool *pool = [NSAutoreleasePool new];
		id newSubject;
		newSubject = [[currentSubjectClass alloc] initWithString: [currentDesc getParametersString]];
		[subjMan addSubject: newSubject
				   toThread: [currentDesc getThreadId]
				   withName: [currentDesc getSubjectAlias]];
		[newSubject release];
		[pool release];

		[gLog add: notice withFormat: @"MPLinker: Subject \"%@\" with alias \"%@\" "
										"added to thread \"%u\" with initialization string \"%@\"",
			[currentDesc getSubjectName],
			[currentDesc getSubjectAlias],
			[currentDesc getThreadId],
			[currentDesc getParametersString]
		];
	}

	[subjMan release];
	[descriptions release];

	return modules;
}

void MPUnloadModules(id linkerState)
{
	NSEnumerator *enumer = nil;
	MPModule *module = nil;

	if(linkerState == nil) return;

	if( [linkerState isKindOfClass: [NSMutableDictionary class]] )
	{
		enumer = [linkerState objectEnumerator];
		while( (module = [enumer nextObject]) != nil )
		{
			[module unloadLibrary];		
		}
	}
}

