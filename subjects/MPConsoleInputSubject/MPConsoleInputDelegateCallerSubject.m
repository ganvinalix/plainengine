#import <MPCore.h>
#import <MPConsoleInputDelegateCallerSubject.h>

NSString *convertToString(const char *type, void *val)
{
	NSMutableString *str = nil;
	#define CHECK_TYPE(T, f)\
		if ((!str) && strcmp(type, @encode(T))==0)\
		{\
			T *t;\
			t = (T*)val;\
			str = [NSString stringWithFormat: f, *t];\
			return str;\
		}
	if (strcmp(type, @encode(void)) == 0)
	{
		return @"(void)";
	}
	CHECK_TYPE(double,		@"%lf");
	CHECK_TYPE(float,		@"%f");
	CHECK_TYPE(int,			@"%d");
	CHECK_TYPE(unsigned,	@"%u");

	return str;
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
	
	if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"dcall"])
	{
		NSArray *arr = [str componentsSeparatedByString: @" "];
		if ([arr count]>=3)
		{
			id object = [[api getObjectSystem] getObjectByName: [arr objectAtIndex: 0]];
			
			char *returnType = malloc([[arr objectAtIndex: 1] length]+2);
			char *methodName = malloc([[arr objectAtIndex: 2] length]+2);

			[[arr objectAtIndex: 1] getCString: returnType
					  maxLength: [[arr objectAtIndex: 1] length]+1
					   encoding: NSUTF8StringEncoding];


			[[arr objectAtIndex: 2] getCString: methodName
					  maxLength: [[arr objectAtIndex: 2] length]+1
					   encoding: NSUTF8StringEncoding];

			SEL methodSelector = sel_getUid(methodName);

			if (!methodSelector) //:-(
			{
				[[api log] add: warning withFormat: @"MPConsoleInputDelegateCallerSubject: Selector \"%s\" is invalid;",
					methodName];
				free(returnType);
				free(methodName);
				return;
			}

			char *types;
			BOOL freeTypes = NO;

			if ([arr count] > 3)
			{
				types = malloc([[arr objectAtIndex: 3] length]+2);
				[[arr objectAtIndex: 3] getCString: types
						  maxLength: [[arr objectAtIndex: 3] length]+1
						   encoding: NSUTF8StringEncoding];
				freeTypes = YES;
			}
			else
			{
				types = "";
			}

			char *sigTypes;
			sigTypes = malloc(strlen(returnType)+strlen(types)+3);
			sprintf(sigTypes, "%s@:%s", returnType, types);
	
			NSMethodSignature *sig;
			sig = [NSMethodSignature signatureWithObjCTypes: sigTypes];
			NSInvocation *inv = [NSInvocation invocationWithMethodSignature: sig];
			[inv setSelector: methodSelector];

			release_bunch argsbunch = relbunch_create();

			unsigned i, argcount = [sig numberOfArguments];
			for (i=2; i<argcount; ++i)
			{
				unsigned int size, al;
				NSGetSizeAndAlignment([sig getArgumentTypeAtIndex: i], &size, &al);
				void *arg = malloc(size);
				if (types[i-2] == 'd')
				{
					double t = [[arr objectAtIndex: i+2] doubleValue];
					memcpy(arg, &t, sizeof(double));
				}
				else
				{
					[[api log] add: error withFormat: @"MPConsoleInputDelegateCallerSubject: type \'%c\' not supported",
						types[i-2]];
				}
				[inv setArgument: arg atIndex: i];
				relbunch_add_pointer(argsbunch, arg);
			}

			[inv invokeWithTarget: object];

			unsigned int size, al;
			NSGetSizeAndAlignment(returnType, &size, &al);
			void *retbuffer = NULL;
			retbuffer = malloc(size);
			[inv getReturnValue: retbuffer];
			free(sigTypes);
			free(methodName);
			relbunch_release(argsbunch);
			if (freeTypes)
			{
				free(types);
			}
			
			[[api log] add: info
				withFormat: @"MPConsoleInputDelegateCallerSubject: return value: \"%@\"",
				convertToString(returnType, retbuffer)];

			free(returnType);
			free(retbuffer);

		}
	}
	else if (str && [[MP_MESSAGE_DATA objectForKey: @"commandname"] isEqual: @"helpdcall"])
	{
		[[api log] add: info withFormat: @"Usage: dcall <objname> <rettype> <msgselector> [<argtypes> {args}]"];
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


