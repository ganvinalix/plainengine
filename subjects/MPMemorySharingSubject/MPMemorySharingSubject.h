#import <MPCore.h>

/*
	Subject for sharing memory between subjects
	Recieves messages:
		createSharedZone;
			Params: name - name of zone;
					size - primary size;

			Behaviour:	Allocates zone with given name If zone exists, widens it if needed
						and posts message "sharedZoneWidened" (see widenSharedZone for details)
						Otherwise posts message "sharedZoneCreated" with params:
							name	- zone name;
							pointer - pointer to zone;
							size 	- zone size;
		widenSharedZone;
			Params: name - name of zone;
					size - new zone size;

			Behaviour:	Widens shared zone. If zone old size is less than new size, nothing happens.
						If zone is not exists, does nothing.
						If zone size was changed, posts message "sharedZoneWidened" with params:
							name	- zone name;
							size	- new zone size;
			
	
*/
@interface MPMemorySharingSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	NSMutableDictionary *zoneDictionary;
}
MP_HANDLER_OF_MESSAGE(createSharedZone);
MP_HANDLER_OF_MESSAGE(widenSharedZone);

@end

