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

	routinesStack = [[NSMutableArray alloc] initWithCapacity: 20];
	messageNameToSubscribedSubjects = [[NSMutableDictionary alloc] initWithCapacity: 20];
	requestNameToSubscribedSubjects = [[NSMutableDictionary alloc] initWithCapacity: 20];
	subjectsWhichHandleAllMessages = [[NSMutableArray alloc] initWithCapacity: 20];
	subjects = [[NSMutableArray alloc] initWithCapacity: 20];
	notifications = [strategy newNotificationQueue];

	//threadTimer = [[MPCodeTimer codeTimerWithSectionName: [NSString stringWithFormat: @"Thread_%d", threadID]] retain];

	selFor_MPHandlerOfAnyMessage = sel_registerName( [MPHandlerOfAnyMessageSelector UTF8String] );

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
	[strategy release];
	[routinesStack release];
	[messageNameToSubscribedSubjects release];
	[requestNameToSubscribedSubjects release];
	[subjectsWhichHandleAllMessages release];
	[subjects release];
	//[threadTimer release];

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
	id<MPSubject> currentSubject = nil;
	while( (currentSubject = [subjectEnumerator nextObject]) != nil )
	{
		[currentSubject start];
		[gLog add: notice withFormat: @"MPThread: Subject [%@] has been started.", currentSubject];
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
	id<MPSubject> currentSubject = nil;
	while( (currentSubject = [subjectEnumerator nextObject]) != nil )
	{
		[currentSubject stop];
		[gLog add: notice withFormat: @"MPThread: Subject [%@] has been stopped.", currentSubject];
	}
	// that's all
	[gLog add: notice withFormat: @"MPThread: Thread %@ has been stopped.", self];
}

//-----
- (void) threadRoutine
{
	if( [strategy isPaused] )
	{
		return;	
	}

	[strategy setUpdating: YES];
	[strategy update];

	id curSubject = nil;
	NSUInteger count = [subjects count], i = 0;
	for(; i < count; ++i)
	{
		curSubject = [subjects objectAtIndex: i];
		if( ![routinesStack containsObject: curSubject] )
		{
			[routinesStack addObject: curSubject];
			[[subjects objectAtIndex: i] update];
			[routinesStack removeObject: curSubject];
		}
	}
	while( [self processNextMessage] ) {}

	[strategy setUpdating: NO];

	MP_SLEEP(1);
}

- (BOOL) processNextMessage
{
	NSNotification *notification = nil;
	NSString *notificationName = nil, *nameForStack = nil;
	NSString *prefix = nil, *suffix = nil;
	NSMutableDictionary *targetToSubscribedObjects = nil;
	id currentSubject = nil;
	BOOL isRequest = NO;

	notification = [notifications getTop];

	if(notification == nil) return NO;

	//[gLog add: info withFormat: @"MPThread: notifications queue is: %@", notifications];
	
	[notification retain];
	[notifications popTop];

#define BIND_VARS(_stackPrefix, _prefix, _suffix, _targetToSubscribedObjects) \
	nameForStack = [NSString stringWithFormat: @#_stackPrefix"%@", notificationName]; \
	prefix = _prefix; \
	suffix = _suffix; \
	targetToSubscribedObjects = _targetToSubscribedObjects;

	notificationName = [notification name];
	isRequest = [[notification object] isKindOfClass: [MPResultCradle class]];
	if(isRequest)
	{
		BIND_VARS(r_, MPHandlerOfRequestPrefix, MPHandlerOfRequestSuffix, requestNameToSubscribedSubjects);
	}
	else
	{
		BIND_VARS(m_, MPHandlerOfMessagePrefix, @"", messageNameToSubscribedSubjects);
	}
#undef BIND_VARS
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
			// if subject appear in this array, then it must conform to selector
			if(!isRequest)
				[currentArrayOfSubjects makeObjectsPerformSelector: currentSelector withObject: [notification userInfo]];
			else
			{
				NSUInteger i = 0;
				for(; i < [currentArrayOfSubjects count]; ++i)
					[[currentArrayOfSubjects objectAtIndex: i] 
											performSelector: currentSelector 
											withObject: [notification userInfo] 
											withObject: [notification object]];
			}
		}

		// deliver message to subjects which are subscribed to all messages
		NSUInteger i = 0, count = [subjectsWhichHandleAllMessages count];
		for (i=0; i<count; ++i)
		{
			currentSubject = [subjectsWhichHandleAllMessages objectAtIndex: i];
			[currentSubject performSelector: selFor_MPHandlerOfAnyMessage 
							withObject: notificationName 
							withObject: [notification userInfo]];
		}
	
		// well done. remove message name
		[routinesStack removeObject: nameForStack];
		[strategy unlockMutex];
	}
	//else
		//[[MPNotificationCenter defaultCenter] postNotification: notification];

	[notification release];

	return YES;
}
//
- (BOOL) addSubject: (id<MPSubject>)aSubject 
{
	// if thread is not stoped
	if([self isWorking]) return NO;

	// if the subject are already in the collection then add it with another name and return
	if ([subjects containsObject: aSubject])
	{
		[gLog add: warning withFormat: @"MPThread: Attempt to add already existing subject: %@", aSubject];
		return NO;
	}

	NSAutoreleasePool *pool = [NSAutoreleasePool new];

	[gLog add: notice withFormat: @"MPThread: Adding subject %@...", aSubject];

	// else add current subject to the collection 
	[subjects addObject: aSubject];

	// bind subject to messages it responds to
	[self bindMethodsOfSubject: aSubject];
	
	// send API to the subject
	MPAPI *api = [MPAPI api];
	[api setCurrentThread: self];
	[aSubject receiveAPI: api];

	[pool release];

	[gLog add: notice withFormat: @"MPThread: Subject %@ has been added to thread %@.", aSubject, self];

	return YES;
}
- (BOOL) removeSubject: (id<MPSubject>)aSubject
{
	NSAssert(aSubject, @"[MPThread removeSubject]: aSubject is nil"); 
	if([self isWorking]) return NO;

	if (![strategy isDone])
	{
		[aSubject stop];
	}
	[self unbindSubject: aSubject];
	[subjects removeObject: aSubject];
	[gLog add: notice withFormat: @"MPThread: Subject %@ has been removed from thread %@.", aSubject, self];

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

- (void) bindMethodsOfSubject: (id<MPSubject>)aSubject
{
	//stuff
	NSString *const prefixes[] = {MPHandlerOfMessagePrefix, MPHandlerOfRequestPrefix};
	NSAssert(elements_count <= 2, @"Number of elements  in the 'targets' enum greater than in the array of target's names.");

	[gLog add: notice withFormat: @"MPThread: Begining of parsing methods of %@ subject ...", aSubject];

	Class classObject = [aSubject class];
	NSUInteger i = 0;
	NSString *nameOfCurrentMethod = nil, *significantPartOfMethodName = nil;
	id <MPMethodList> methodList = MPGetMethodListForClass(classObject);

	// method list iterating and registration of specific methods
	while( [methodList nextMethod] )
	{
		nameOfCurrentMethod = NSStringFromSelector([methodList methodName]);
		if( ![nameOfCurrentMethod hasPrefix: MPHandlerPrefix] )
			continue;

		significantPartOfMethodName = [nameOfCurrentMethod substringFromIndex: [MPHandlerOfMessagePrefix length]];
		NSRange divider = [significantPartOfMethodName rangeOfString: @":"];
		significantPartOfMethodName = [significantPartOfMethodName substringToIndex: divider.location];

		// in this loop i changes from message_receiving to request_receiving, 
		// thuns we register handlers for messages, feature adding, feature removing and requests.
		for(i = 0; i < elements_count; ++i)
			if( [nameOfCurrentMethod hasPrefix: prefixes[i]] )
			{
				[self bindSubject: aSubject to: i withName: significantPartOfMethodName];
				[gLog add: notice withFormat: 
						@"MPThread: The %@ handler for [%@] has been successfully binded.", 
						prefixes[i], 
						significantPartOfMethodName];
			}
	} // while

	// register the handler for all messages if any
	if( [aSubject respondsToSelector: selFor_MPHandlerOfAnyMessage] )
	{
		[subjectsWhichHandleAllMessages addObject: aSubject];
		[gLog add: notice withFormat: @"MPThread: The handler for any event has been successfully binded."];
	}

	[gLog add: notice withFormat: @"MPThread: End of parsing."];
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
	[self threadRoutine];
}

- (NSString*) description
{
	NSEnumerator *enumer = [subjects objectEnumerator];
	id subject;
	//NSMutableString *description = [NSMutableString stringWithFormat: @"(%p with ID [%d]: ", self, threadID];
	NSMutableString *description = [NSMutableString stringWithFormat: @"(ID [%d]: ",threadID];
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

