#import <MPCore.h>
#import <MPConsoleInputDelegateCallerSubject.h>

NSString *convertToString(const char *type, void *val)
{
	#define CHECK_TYPE(T, f)\
		if (strcmp(type, @encode(T))==0)\
		{\
			T *t;\
			t = (T*)val;\
			return [NSString stringWithFormat: f, *t];\
		}
	if (!type)
	{
		return @"(ERROR)";
	}
	if (strcmp(type, @encode(void)) == 0)
	{
		return @"(void)";
	}
	CHECK_TYPE(double,		@"%lf");
	CHECK_TYPE(float,		@"%f");
	CHECK_TYPE(int,			@"%d");
	CHECK_TYPE(unsigned,	@"%u");
	CHECK_TYPE(long,		@"%ld");
	CHECK_TYPE(long long,	@"%lld");

	return @"(ERROR)";
	#undef CHECK_TYPE
}

@implementation MPConsoleInputDelegateCallerSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
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

}

MP_HANDLER_OF_MESSAGE(consoleInput)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *str = [MP_MESSAGE_DATA objectForKey: @"commandparams"];
	
	if	((str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"dcall"]) ||
		(str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"qdcall"]) )
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=2)
		{
			release_bunch rbunch = relbunch_create();

			id object = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			
			char *methodName = malloc([[arr objectAtIndex: 1] length]+2);
			relbunch_add_pointer(rbunch, methodName);

			[[arr objectAtIndex: 1] getCString: methodName
					  maxLength: [[arr objectAtIndex: 1] length]+1
					   encoding: NSUTF8StringEncoding];

			SEL methodSelector;
			NSMethodSignature *sig;

			getSelectorAndMethodSignature(object, methodName, &methodSelector, &sig);

			if (!sig)
			{
				[[api log] add: error withFormat: @"MPConsoleInputDelegateCallerSubject: Selector \"%s\" is invalid;",
					methodName];
				relbunch_release(rbunch);
				return;
			}

			NSInvocation *inv = [[NSInvocation invocationWithMethodSignature: sig] retain];
			[inv setSelector: methodSelector];
			[inv setTarget: object];

			unsigned argcount = [sig numberOfArguments];
			
			if ([arr count] < argcount) //(argcount-2) - arguments count without hidden params, and (argcount-2+2) is valid command arguments count
			{
				[[api log] add: error withFormat: @"MPConsoleInputDelegateCallerSubject: Not enough arguments;"];
				relbunch_release(rbunch);
				return;
			}

			if ([arr count] > argcount)
			{
				[[api log] add: warning withFormat: @"MPConsoleInputDelegateCallerSubject: Too many arguments, redundant ones had been omitted;"];
			}

			unsigned i;
			for (i=2; i<argcount; ++i)
			{
				unsigned int size;
				NSGetSizeAndAlignment([sig getArgumentTypeAtIndex: i], &size, NULL);
				void *arg = malloc(size);
				relbunch_add_pointer(rbunch, arg);
				BOOL found=NO;
				#define DO_TYPE_CHECK(type, strmeth)\
					if (!found && (strcmp([sig getArgumentTypeAtIndex: i], @encode(type)) == 0))\
					{\
						type t = [[arr objectAtIndex: i] strmeth];\
						memcpy(arg, &t, sizeof(t));\
						found = YES;\
					}
					

				DO_TYPE_CHECK(double,		doubleValue);
				DO_TYPE_CHECK(float,		floatValue);
				DO_TYPE_CHECK(unsigned,		intValue);
				DO_TYPE_CHECK(int,			intValue);
				DO_TYPE_CHECK(long,			longValue);
				DO_TYPE_CHECK(long long,	longLongValue);

				#undef DO_TYPE_CHECK

				if (!found)
				{
					[[api log] add: error withFormat: @"MPConsoleInputDelegateCallerSubject: type \'%s\' not supported",
	   								[sig getArgumentTypeAtIndex: i]];
					relbunch_release(rbunch);
					return;
				}
				[inv setArgument: arg atIndex: i];
			}


			unsigned int size;
			size = [sig methodReturnLength];
			void *retbuffer = NULL;
			retbuffer = malloc(size);
			relbunch_add_pointer(rbunch, retbuffer);

			[inv invoke];
			[inv getReturnValue: retbuffer];
			[inv release];

			if ([[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"dcall"])
			{
				[[api log] add: info
						withFormat: @"MPConsoleInputDelegateCallerSubject: return value: \"%@\"",
						convertToString([sig methodReturnType], retbuffer)];
			}

			relbunch_release(rbunch);

		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"helpdcall"])
	{
		[[api log] add: info withFormat: @"Call object method with result printing:\tdcall <objname> <msgselector> {args}"];
		[[api log] add: info withFormat: @"Call object method without result printing:\tqdcall <objname> <msgselector> {args}"];
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"help"])
	{
		[[api log] add: info withFormat: @"helpdcall - MPConsoleInputDelegateCallerSubject help"];
	}

	[pool release];
}

- (void) update
{

}

@end


