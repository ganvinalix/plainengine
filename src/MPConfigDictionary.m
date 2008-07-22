#import <MPConfigDictionary.h>

NSDictionary *MPCreateConfigDictionary(NSDictionary *aDefaults, NSDictionary *aUserDictionary)
{
	// cann't init instance if received invalid parameters
	if(aDefaults == nil) 
	{
		return nil; 
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// create reslt dictionary
	// firstly create mutable copy of defaultsDictionary
	NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionaryWithDictionary: aDefaults];
	// temporary variables
	id currentResultKey = nil, currentUserObject = nil;
	// keys enumerator of resultDictionary
	NSEnumerator *enm = [resultDictionary keyEnumerator];
	while( (currentResultKey = [enm nextObject]) && (aUserDictionary != nil) )
	{
		// if there are a value in userDictionary...
		currentUserObject = [aUserDictionary objectForKey: currentResultKey];
		if(currentUserObject != nil)
		{
			// ...use its value in resultDictionary
			[resultDictionary setObject: currentUserObject forKey: currentResultKey];
		}	
	}
	// all done
	// we must retain resultDictionary before pool releasing
	[resultDictionary retain];
	// release pool
	[pool release];

	return resultDictionary;
}
