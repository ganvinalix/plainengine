#import <MPCore.h>
#import <MPConsoleInputObjectManipulatorSubject.h>

@implementation MPConsoleInputObjectManipulatorSubject

id strToHandle(id string)
{
	return [[[NSNumber alloc] INIT_WITH_MPHANDLE: [string MPHANDLE_VALUE]] autorelease];
}

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	handler = [[MPMapper alloc] initWithConverter: &strToHandle];
	objectsArray = [NSMutableArray new];
	return self;
}

- init
{
	return [self initWithString: @""];
}

- (void) dealloc
{
	if (api)
	{
		[api release];
	}
	[objectsArray release];
	[handler release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	 api = [anAPI retain];
}

- (void) start
{

}

- (void) stop
{
	[objectsArray removeAllObjects];
}

void parseUserInfoParams(NSString *str, id dict, NSUInteger startingWord)
{
	NSUInteger i, count=[str length];
	int start=-1;
	//++startingWord;
	for (i=0; i<count; ++i)
	{
		if ([str characterAtIndex: i]==' ')	
		{
			if(!(--startingWord))
			{
				start = i+1;
				break;
			}
		}
	}
	if ((start != -1) && (start < count))
	{
		NSString *prms = [str substringFromIndex: start];
		NSArray *arr = [prms componentsSeparatedByString: @"/"];
		count = [arr count];
		for (i=0; i<count; ++i)
		{
			NSMutableString *paramname = [NSMutableString string];
			NSMutableString *paramvalue = [NSMutableString string];
			separateString([arr objectAtIndex: i], paramname, paramvalue, @"=");
			[dict setObject: paramvalue forKey: paramname];
		}
	}
}
MP_HANDLER_OF_MESSAGE(consoleInput)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *str = [MP_MESSAGE_DATA objectForKey: @"commandparams"];
	
	if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"newobj"])
	{
		id obj=[[api getObjectSystem] newObjectWithName: str];
		[objectsArray addObject: obj];
		[obj release];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"rmobj"])
	{
		id obj = [[api getObjectSystem] getObjectByName: str];
		[objectsArray removeObject: obj];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"clnobj"])
	{
		id obj = [[api getObjectSystem] getObjectByName: str];
		[obj clean];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objsetfwp"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id obj = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			NSString *fd;
			if ([arr count]>=3)
			{
				fd = [arr objectAtIndex: 2];
			}
			else
			{
				fd = [NSString string];
			}
			
			id dict = [MPMutableDictionary new];
			parseUserInfoParams(str, dict, 3);
			[obj setFeature: [arr objectAtIndex: 1] toValue: [MPVariant variantWithString: fd] userInfo: dict];
			[dict release];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objsetf"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id obj = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			NSString *fd;
			if ([arr count]>=3)
			{
				fd = [arr objectAtIndex: 2];
			}
			else
			{
				fd = [NSString string];
			}

			[obj setFeature: [arr objectAtIndex: 1] toValue: [MPVariant variantWithString: fd]];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objgetf"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id obj = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			id<MPVariant> data = [obj getFeatureData: [arr objectAtIndex: 1]];
			[[api log] add: info withFormat: @"Value of feature \"%@\" of object \"%@\" is: \"%@\"",
									[arr objectAtIndex: 1],
									obj,
									data];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objrmf"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id obj = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			[obj removeFeature: [arr objectAtIndex: 1]];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objrmfwp"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id obj = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			
			id dict = [MPMutableDictionary new];
			parseUserInfoParams(str, dict, 2);
			[obj removeFeature: [arr objectAtIndex: 1] userInfo: dict];
			[dict release];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"cpobj"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			id obj = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			[obj copyWithName: [arr objectAtIndex: 1]];
		}
		else if ([arr count]>=1)
		{
			id obj = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			[obj copy];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objpf"])
	{
		id obj = [[api getObjectSystem] getObjectByName: str];
		if (obj)
		{
			NSMutableString *featuresString = [NSMutableString string];
			NSEnumerator *enumer = [[obj getAllFeatures] keyEnumerator];
			NSString *key;
			while ((key = [enumer nextObject]) != nil)
			{
				id<MPVariant> value = [[obj getAllFeatures] objectForKey: key];
				[featuresString appendFormat: @"\n%@=\"%@\"", key, value];
			}
			[[api log] add: info withFormat: @"Features of object \"%@\" are: %@", str, featuresString];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objall"])
	{
		NSArray *objects = [[api getObjectSystem] getAllObjects];
		NSUInteger i, count = [objects count];
		for (i=0; i<count; ++i)
		{
			[[api log] add: info withFormat: @"-%@", [objects objectAtIndex: i]]; 
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objbyf"])
	{
		NSArray *objects = [[api getObjectSystem] getObjectsByFeature: str];
		NSUInteger i, count = [objects count];
		for (i=0; i<count; ++i)
		{
			[[api log] add: info withFormat: @"-%@ [%@]",
							[objects objectAtIndex: i], [[objects objectAtIndex: i] getFeatureData: str]]; 
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objh"])
	{
		id obj = [[api getObjectSystem] getObjectByName: str];
		if (obj)
		{
			[[api log] add: info withFormat: @"Handle of object \"%@\" is: %@", str, [obj getHandle]];
		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objn"])
	{
		id obj = [[api getObjectSystem] getObjectByHandle: [handler getObject: str]];
		if (obj)
		{
			[[api log] add: info withFormat: @"Name of object with handle %@ is: \"%@\"",
							[handler getObject: str], [obj getName]];
		}
	}
	/*
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objsave"])
	{
		[[api getObjectSystem] saveToFile: str];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"objload"])
	{
		[[api getObjectSystem] loadFromFile: str];
	}
	*/
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"helpobj"])
	{
		[[api log] add: info withFormat:
			@"\nnewobj <nam>\t\t\t\t - adds object with name 'nam'\n"
			 "rmobj <nam>\t\t\t\t - removes object 'nam'\n"
			 "clnobj <nam>\t\t\t\t - cleans object 'nam'\n"
			 "objsetf <nam> <fn> [<fd>]\t\t - sets feature 'fn' on object 'nam' to 'fd'\n"
			 "objsetfwp <nam> <fn> <fd> par1=par1value/par2=par2value...\t - \n"
			 										"\t\t\t\t\tsets feature 'fn' on object 'nam' to 'fd' with user info\n"
			 "objrmf <nam> <fn>\t\t\t - removes feature 'fn' from object 'nam'\n"
			 "objrmfwp <nam> <fn> par1=par1value/par2=par2value...\t - \n"
			 										"\t\t\t\t\tremoves feature 'fn from object 'nam' with user info\n"
			 "objpf <nam>\t\t\t\t - prints features of object 'nam'\n"
			 "objall \t\t\t\t\t - prints list of all objects\n"
			 "objbyf <fn>\t\t\t\t - lists objects with feature 'fn'\n"
			 "cpobj <nam> [<newnam>]\t\t\t - copies object 'nam'. Copy name is 'newnam'\n"
			 //"objload <filename>\t\t - loads objects from file 'filename'\n"
			 //"objsave <filename>\t\t - saves objects to file 'filename'\n"
			 "objh <nam>\t\t\t\t - prints handle of object 'nam'\n"
			 "objn <han>\t\t\t\t - prints name of object with handle 'han'\n"
		];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"help"])
	{
		[[api log] add: info withFormat: @"helpobj - MPConsoleInputObjectManipulatorSubject help"];
	}
	[pool release];
}

- (void) update
{

}

@end


