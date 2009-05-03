#import <MPConfigFacilities.h>
#import <MPLog.h>

id MPBuildPlistFromData(NSData *plistData)
{
	[gLog add: notice withFormat: @"Try to build plist from data.\n"];
	
	NSString *error_desc = nil;
	[plistData retain];
	id plist = [NSPropertyListSerialization propertyListFromData: plistData
											mutabilityOption: NSPropertyListImmutable
													  format: NULL
											errorDescription: &error_desc];
	[plistData release];

	if(!plist) 
	{
		[gLog add: error withFormat: @"There were error: \n, %@ \n", error_desc];
	}
	else 
		[gLog add: notice withFormat: @"Success.\n"];
	
	BOOL valid = [plist isKindOfClass: [NSDictionary class]];
	NSCAssert(valid, @"Invalid plist structure!");
	
	if(!valid)
		plist = nil;
	
	return plist;
}

NSDictionary *MPBuildLogOptionsFromPlist(NSDictionary *plist)
{
	// make logfile defaults
	NSDictionary *logDefaults = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool: YES], @"enabled",
																			@"./hist.log", @"path", nil];
	id logOpts = [plist objectForKey: @"LogFile"];
	if(logOpts)
		NSCAssert( [logOpts isKindOfClass: [NSDictionary class]], @"Invalid plist structure!");
	
	NSDictionary *logOptsResult = MPCreateConfigDictionary(logDefaults, logOpts);
	
	return logOptsResult;
}

NSString *MPPreprocessString(NSString *str, NSDictionary *userOpts)
{
	NSMutableString *outputStr = [NSMutableString string];
	NSString *currentPart = nil;
	NSArray *paramAndValue = nil;

	NSArray *parts = [str componentsSeparatedByString: @"$"];

	if( [parts count]%2 != 1 )
	{
		[gLog add: error withFormat: @"MPPreprocessString: Syntax error - unfinshed variable defenition."];
		return nil;	
	}

	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	NSUInteger i;
	for(i = 0; i < [parts count]; ++i)
	{
		currentPart = [parts objectAtIndex: i];
		if( ((i+1) % 2) == 1 )
		{
			[outputStr appendString: currentPart];
		}
		else if( [currentPart isEqualToString: @""] )
		{
			[outputStr appendString: @"$"];
		}
		else
		{
			paramAndValue = [currentPart componentsSeparatedByString: @"="];

			if( [paramAndValue count] != 2 )
				continue;

			NSString *userValue = [userOpts objectForKey: [paramAndValue objectAtIndex: 0]];
			if(!userValue)
				userValue = [paramAndValue objectAtIndex: 1];

			[outputStr appendString: userValue];
		}
	}

	[pool release];

	return outputStr;
}

NSDictionary *MPBuildDictionaryFromCmd(int agrc, const char *argv[])
{
	NSMutableDictionary *result = [NSMutableDictionary new];

	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	NSMutableString *allargs = [NSMutableString string];
	NSString *str_i = nil;
	NSArray *parts = nil;

	int i = 1;
	for(; i < agrc; ++i)
	{
		str_i = [NSString stringWithUTF8String: argv[i]];

		if(i != 1)
			[allargs appendString: @" "];
		[allargs appendString: str_i];

		[result setObject: str_i forKey: [NSString stringWithFormat: @"arg%d", i]];

		parts = [str_i componentsSeparatedByString: @"="];

		if( [parts count] == 2 )
			[result setObject: [parts objectAtIndex: 1] forKey: [parts objectAtIndex: 0]];
	}

	[result setObject: allargs forKey:  @"argall"];

	[pool release];

	return [result autorelease];
}
