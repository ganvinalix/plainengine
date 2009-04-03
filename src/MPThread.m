#import <MPThread.h>
#import <MPAPI.h>
#import <common.h>
#import <core_constants.h>
#import <MPNotifications.h>
#import <MPUtility.h>

#import <MPForkedThreadStrategy.h>

// implementation of MPThread
@implementation MPThread
- initWithStrategy: (MPThreadStrategy *)aStrategy withID: (unsigned)thId;
{
	if(aStrategy == nil) return nil;

	[super init];

	threadID = thId;

	strategy = [aStrategy retain];

	subjects = [[NSMutableDictionary alloc] init];
	routinesStack = [[NSMutableArray alloc] initWithCapacity: 20];
	messageNameToSubscribedSubjects = [[NSMutableDictionary alloc] initWithCapacity: 20];
	requestNameToSubscribedSubjects = [[NSMutableDictionary alloc] initWithCapacity: 20];
	subjectsWhichHandleAllMessages = [[NSMutableArray alloc] initWithCapacity: 20];
	allSubjects = [[NSMutableArray alloc] initWithCapacity: 20];
	notifications = [strategy newNotificationQueue];

	threadTimer = [MPCodeTimer codeTimerWithSectionName: [NSString stringWithFormat: @"Thread_%d", threadID]];

	//mutableStringPool = [[MPPool alloc] initWithClass: [NSMutableString class]];
	//cstrconv = [[MPStringToCStringConverter alloc] init];

	handleMessageWithName = sel_registerName( [MPHandlerOfAnyMessageSelector UTF8String] );

	[strategy setWorking: NO];
	[strategy setDone: YES];
	[strategy setPaused: NO];
	[strategy setPrepared: NO];
	
	return self;
}
- init
{
	return [self initWithStrategy: [MPThreadStrategy forkedStrategy] withID: 0];
}
- (void) dealloc
{
	[self stop];

	[notifications release];
	[subjects release];
	[strategy release];
	[routinesStack release];
	[messageNameToSubscribedSubjects release];
	[requestNameToSubscribedSubjects release];
	[subjectsWhichHandleAllMessages release];
	[allSubjects release];
	//[mutableStringPool release];
	//[cstrconv release];
	[threadTimer release];

	[super dealloc];
}
+ thread
{
	return [[[MPThread alloc] init] autorelease];
}
+ threadWithStrategy: (MPThreadStrategy *)aStrategy withID: (unsigned)thId;
{
	return [[[MPThread alloc] initWithStrategy: aStrategy withID: thId] autorelease];
}
//-----
- (BOOL) isWorking
{
	return [strategy isWorking];
}
- (BOOL) isPaused
{
	return [strategy isPaused];
}
- (BOOL) isPrepared
{
	return [strategy isPrepared];
}
- (BOOL) isUpdating
{
	return [strategy isUpdating];
}
- (void) prepare
{
	if( [self isWorking] ) 
	{
		[gLog add: warning withFormat: @"MPThread: Attempt to 'prepare' already working thread."];
		return;
	}

	if( [self isPrepared] ) 
	{
		[gLog add: warning withFormat: @"MPThread: Attempt to 'prepare' already prepared thread."];
		return;
	}

	// registering in notification center
	[[MPNotificationCenter defaultCenter]
		addObserver: notifications 
		selector: @selector(receiveNotification:) 
		name: nil object: nil];

	// sending start to all subjects
	NSEnumerator *subjectEnumerator = [subjects objectEnumerator];
	NSEnumerator *keysEnumerator = [subjects keyEnumerator];
	id<MPSubject> currentSubject = nil, currentName = nil;
	while( (currentSubject = [subjectEnumerator nextObject]) && (currentName = [keysEnumerator nextObject]) )
	{
		[currentSubject start];
		[gLog add: notice withFormat: @"MPThread: Subject [%@] has been started.", currentName];
	}

	[strategy setPrepared: YES];

	[gLog add: notice withFormat: @"MPThread: Thread %@ has been prepared.", self];
}
- (void) start
{
	if( [self isWorking] ) 
	{
		[gLog add: warning withFormat: @"MPThread: Attempt to start already working thread."];
		return;
	}

	if( ![self isPrepared] )
	{
		[self prepare];
	}

	[strategy setDone: NO];
	// lets go!
	[strategy startPerformingSelector: @selector(threadRoutine) toTarget: self];
	[gLog add: notice withFormat: @"MPThread: Thread %@ has been started.", self];
}
- (void) stop
{
	if([strategy isDone]) 
	{
		return;
	}

	// unsubscribing from notifications
	[[MPNotificationCenter defaultCenter] removeObserver: notifications];

	[strategy setDone: YES];
	[strategy setPrepared: NO];

	// remember current time
	NSDate *startTime = [NSDate date];
	// waiting until forked thread join us 
	NSTimeInterval maxTime = - (MPTHREAD_MAX_WAIT_FOR_UPDATE_TIME)/1000;
	while( [self isWorking] )
	{
		if( [startTime timeIntervalSinceNow] < maxTime ) break;
		[strategy wait];
	}
	// now sending stop to all subjects
	NSEnumerator *subjectEnumerator = [subjects objectEnumerator];
	NSEnumerator *keysEnumerator = [subjects keyEnumerator];
	id<MPSubject> currentSubject = nil, currentName = nil;
	while( (currentSubject = [subjectEnumerator nextObject]) && (currentName = [keysEnumerator nextObject]) )
	{
		[currentSubject stop];
		[gLog add: notice withFormat: @"MPThread: Subject [%@] has been stopped.", currentName];
	}
	// that's all
	[gLog add: notice withFormat: @"MPThread: Thread %@ has been stopped.", self];
}
//-----
- (void) threadRoutine
{
	if([strategy isPaused])
	{
		return;	
	}
	//
	//
	[strategy setUpdating: YES];

	[strategy update];

	id curSubject = nil;
	NSUInteger count = [allSubjects count], i;
	for(i=0; i<count; ++i)
	{
		curSubject = [allSubjects objectAtIndex: i];
		if( ![routinesStack containsObject: curSubject] )
		{
			[routinesStack addObject: curSubject];
			[[allSubjects objectAtIndex: i] update];
			[routinesStack removeObject: curSubject];
		}
	}
	while( [self processNextMessage] );

	[strategy setUpdating: NO];

	MP_SLEEP(1);
}
- (BOOL) processNextMessage
{
	NSNotification *notification = nil;
	NSString *notificationName = nil;
	NSString *nameForStack = nil;
	NSString *prefix = nil, *suffix = nil;
	NSMutableDictionary *targetToSubscribedObjects = nil;
	//NSEnumerator *enumer = nil;
	id currentSubject = nil;
	BOOL isRequest = NO;

	notification = [notifications getTop];

	if(notification == nil) return NO;

	//[gLog add: info withFormat: @"MPThread: notifications queue is: %@", notifications];
	
	[notification retain];
	[notifications popTop];


	notificationName = [notification name];
	isRequest = [[notification object] isKindOfClass: [MPResultCradle class]];
	if(isRequest)
	{
		nameForStack = [NSString stringWithFormat: @"r_%@", notificationName];
		prefix = MPHandlerOfRequestPrefix;
		suffix = MPHandlerOfRequestSuffix;
		targetToSubscribedObjects = requestNameToSubscribedSubjects;
	}
	else
	{
		nameForStack = [NSString stringWithFormat: @"m_%@", notificationName];
		prefix = MPHandlerOfMessagePrefix;
		suffix = @"";
		targetToSubscribedObjects = messageNameToSubscribedSubjects;
	}
	//[gLog add: info withFormat: @"MPThread: message with name: '%@' has been recieved; stack: %@; Thread: %@", notificationName, routinesStack, self];

	// not necessary to process message if same one is deferred already
	if( ![routinesStack containsObject: nameForStack] )
	{	
		[strategy lockMutex];
	
		// else add its name into set
		[routinesStack addObject: nameForStack];
	
		// ok. processing message now
		NSString *methodName = [NSString stringWithFormat: @"%@%@:%@", prefix, notificationName, suffix];
		SEL currentSelector = sel_getUid( [methodName UTF8String] );

		NSArray *currentArrayOfSubjects = [targetToSubscribedObjects objectForKey: notificationName];
		if(currentArrayOfSubjects != nil)
		{
			// if subject appear in this array, then it must conforms to selector
			if(!isRequest)
				[currentArrayOfSubjects makeObjectsPerformSelector: currentSelector withObject: [notification userInfo]];
			else
			{
				NSUInteger i = 0;
				for(; i < [currentArrayOfSubjects count]; ++i)
				{
					[[currentArrayOfSubjects objectAtIndex: i] performSelector: currentSelector withObject: [notification userInfo] withObject: [notification object]];
				}
			}
		}

		NSUInteger i = 0, count = [subjectsWhichHandleAllMessages count];
		for (i=0; i<count; ++i)
		{
			currentSubject = [subjectsWhichHandleAllMessages objectAtIndex: i];
			[currentSubject performSelector: 
	   			handleMessageWithName withObject: notificationName withObject: [notification userInfo]];
		}
	
		// well done. remove message name
		[routinesStack removeObject: nameForStack];
		
		[strategy unlockMutex];
	}
	else
	{
		//[[MPNotificationCenter defaultCenter] postNotification: notification];
	}

	[notification release];

	return YES;
}
//
- (BOOL) addSubject: (id<MPSubject>)aSubject withName: (NSString *)aName
{
	// stuff
	NSString *const prefixes[] = {MPHandlerOfMessagePrefix, MPHandlerOfRequestPrefix};
	NSAssert(elements_count <= 2, @"Number of elements  in the 'targets' enum greater than in the array of target's names.");

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	// if thread is not stoped
	if([self isWorking]) return NO;

	// if the subject are already in the collection then return
	if ([subjects objectForKey: aName])
	{
		return [self addSubject: aSubject withName: [NSString stringWithFormat: @"%@_", aName]];
	}
	// else add current subject to the collection 
	[subjects setObject: aSubject forKey: aName];
	[allSubjects addObject: aSubject];

	// selectors registration here
	[gLog add: notice withFormat: @"MPThread: Begining of parsing methods of %@ subject with name %@...", aSubject, aName];

	Class classObject = [aSubject class];
	NSUInteger i = 0;
	NSString *nameOfCurrentMethod = nil, *significantPartOfName = nil;

	id <MPMethodList> methodList = MPGetMethodListForClass(classObject);

	// method list iterating and registration of specific methods
	if(methodList != nil)
	{
		do
		{
			nameOfCurrentMethod = [NSString stringWithUTF8String: sel_getName([methodList getMethodName])];
			if( [nameOfCurrentMethod hasPrefix: MPHandlerPrefix] )
			{
				significantPartOfName = [nameOfCurrentMethod substringFromIndex: [MPHandlerOfMessagePrefix length]];
				NSRange divider = [significantPartOfName rangeOfString: @":"];
				significantPartOfName = [significantPartOfName substringToIndex: divider.location];

				// in this loop i changes from message_receiving to request_receiving, 
				// thuns we register handlers for messages, feature adding, feature removing and requests.
				for(i = 0; i < elements_count; ++i)
				{
					if( [nameOfCurrentMethod hasPrefix: prefixes[i]] )
					{
						[self bindSubject: aSubject to: i withName: significantPartOfName];
						[gLog add: notice withFormat: 
								  @"MPThread: The %@ handler for [%@] has been successfully binded.", prefixes[i], significantPartOfName];
					}	
				}

			} // if hasPrefix
		} while([methodList moveToNext]);// while
	} // if methodList != NULL

	// register the handler for all messages if any
	if( [aSubject respondsToSelector: handleMessageWithName] )
	{
		[subjectsWhichHandleAllMessages addObject: aSubject];
		[gLog add: notice withFormat: @"MPThread: The handler for any event has been successfully added binded."];
	}

	[gLog add: notice withFormat: @"MPThread: End of parsing."];
	// end of registration

	// send API to the subject
	MPAPI *api = [MPAPI api];
	[api setCurrentThread: self];
	[aSubject receiveAPI: api];

	[pool release];

	[gLog add: notice withFormat: @"MPThread: Subject with name \"%@\" has been added to thread %@.", aName, self];

	return YES;
}

- (BOOL) removeSubjectWithName: (NSString *)aName
{
	if([self isWorking]) return NO;

	id subj;
	subj = [subjects objectForKey: aName];
	if (!subj)
	{
		return NO;
	}
	[subj stop];
	[self unbindSubject: subj];
	[subjects removeObjectForKey: aName];
	[allSubjects removeObject: subj];
	[gLog add: notice withFormat: @"MPThread: Subject with name \"%@\" has been removed from thread %@.", aName, self];

	return YES;
}

- (void) pause
{
	if( ![self isWorking] ) return;

	[strategy setWorking: NO];
	[strategy setPaused: YES];
	[gLog add: notice withFormat: @"MPThread: Thread %@ has been paused.", self];
}
- (void) resume
{
	[strategy setWorking: YES];
	[strategy setPaused: NO];
	[gLog add: notice withFormat: @"MPThread: Thread %@ has been resumed.", self];
}
- (id<MPSubject>) getSubjectByName: (NSString *)aName
{
	[strategy lockMutex];
	id <MPSubject> subj = [subjects objectForKey: aName];
	[strategy unlockMutex];
	NSAssert([subj conformsToProtocol: @protocol(MPSubject)] == YES,
		       	@"there are non subject object in the subjects dictionary!");
	return [[subj retain] autorelease];
}
- (BOOL) bindSubjectWithName: (NSString *)aSubjectName to: (subject_binding_target)aTarget withName: (NSString *)aName
{
	return [self bindSubject: [self getSubjectByName: aSubjectName] to: aTarget withName: aName];
}
- (BOOL) bindSubject: (id<MPSubject>)aSubject to: (subject_binding_target)aTarget withName: (NSString *)aName
{
	NSMutableDictionary *collections[] = {messageNameToSubscribedSubjects, requestNameToSubscribedSubjects};
	NSAssert(elements_count <= 2, @"Number of elements  in the 'targets' enum greater than in the 'collections' array.");

	NSMutableDictionary *targetToSubscribedObjects = collections[aTarget];

	NSAssert(aName, @"nil instead of the string with the target's name.");

	NSMutableArray *currentArrayOfSubjects = nil;
	// now locking and approving changes
	[strategy lockMutex];
	[targetToSubscribedObjects retain];
	currentArrayOfSubjects = [targetToSubscribedObjects objectForKey: aName];
	if(currentArrayOfSubjects == nil)
	{
		currentArrayOfSubjects = [NSMutableArray arrayWithCapacity: 20];
		[targetToSubscribedObjects setObject: currentArrayOfSubjects forKey: aName];
	}
	if( ![currentArrayOfSubjects containsObject: aSubject] )
	{
		[currentArrayOfSubjects addObject: aSubject];
	}
	[targetToSubscribedObjects release];
	// unlocking
	[strategy unlockMutex];

	return YES;
}
- (void) unbindSubject: (id<MPSubject>)aSubject
{
	NSEnumerator *subscibedSubjectsEnumerator;
	id currentArrayOfSubjects = nil;

	id collections[] = {messageNameToSubscribedSubjects, requestNameToSubscribedSubjects};
	const NSUInteger collectionsCount = 2;
	NSUInteger i = 0;

	[strategy lockMutex];
	
	for(i = 0; i < collectionsCount; ++i)
	{
		subscibedSubjectsEnumerator = [collections[i] objectEnumerator];
		while( (currentArrayOfSubjects = [subscibedSubjectsEnumerator nextObject]) != nil )
		{
			[currentArrayOfSubjects removeObject: aSubject];
		}
	}

	[subjectsWhichHandleAllMessages removeObject: aSubject];

	[strategy unlockMutex];
}

- (void) yield
{
	//[strategy update];

	//NSUInteger count = [allSubjects count], i;
	//for (i=0; i<count; ++i)
	//{
		//[[allSubjects objectAtIndex: i] update];
	//}
	//[self processNextMessage];
	[self threadRoutine];
}

- (NSString*) description
{
	NSEnumerator *enumer = [allSubjects objectEnumerator];
	id subject;
	NSMutableString *description = [NSMutableString stringWithFormat: @"(%p with ID [%d]: ", self, threadID];
	BOOL first = YES;
	while ((subject = [enumer nextObject]) != nil)
	{
		if (first)
		{
			[description appendString: NSStringFromClass([subject class])];
			first = NO;
		}
		else
		{
			[description appendFormat: @", %@", NSStringFromClass([subject class])];
		}
	}
	[description appendString: @")"];
	return description;
}

- (unsigned) getID
{
	return threadID;
}

@end

