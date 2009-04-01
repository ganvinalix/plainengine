#import <MPConfigDictionary.h>

NSDictionary *MPCreateConfigDictionary(NSDictionary *aDefaults, NSDictionary *aUserDictionary)
{
	// cann't init instance if received invalid parameters
	if(aDefaults == nil) 
	{
		return nil; 
	}
	if(aUserDictionary == nil)
	{
		return [[aDefaults retain] autorelease];
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// create reslt dictionary
	// firstly create mutable copy of defaultsDictionary
	NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] initWithDictionary: aDefaults];
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
			[resultDictionary setObject: [[currentUserObject copy] autorelease] forKey: currentResultKey];
		}	
	}
	// all done
	// release pool
	[pool release];

	return [resultDictionary autorelease];
}
