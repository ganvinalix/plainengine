#import <locale.h>

#import <MPCore.h>
#import <MPLuaSubject.h>
#import <MPLuaExports.h>
#import <MPLuaHelpers.h>

@implementation MPLuaSubject

NSLock *luaGlobalLock = nil;
NSMutableDictionary *locksDictionary = nil;
NSDictionary *encodingsDictionary = nil;

+(void) load
{
	if (!luaGlobalLock)
	{
		luaGlobalLock = [NSRecursiveLock new];
	}
	if (!locksDictionary)
	{
		locksDictionary = [NSMutableDictionary new];
	}
	if (!encodingsDictionary)
	{
		NSMutableDictionary *encodingsDictionaryMutable;
		encodingsDictionaryMutable = [NSMutableDictionary new];

		#define ADD_TYPE_TO_ENCODINGS_DICTIONARY(type, name)\
			[encodingsDictionaryMutable setObject: [NSString stringWithUTF8String: @encode(type)] forKey: [NSString stringWithUTF8String: #name]]

		ADD_TYPE_TO_ENCODINGS_DICTIONARY(double, double);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(float, float);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(long, long);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(unsigned long, ulong);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(long long, longlong);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(unsigned long long, ulonglong);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(char, char);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(unsigned char, uchar);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(short, short);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(unsigned short, ushort);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(int, int);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(unsigned int, uint);
		ADD_TYPE_TO_ENCODINGS_DICTIONARY(MPHandle, mphandle);

		#undef ADD_TYPE_TO_ENCODINGS_DICTIONARY

		encodingsDictionary = [encodingsDictionaryMutable copy];
		[encodingsDictionaryMutable release];
		NSLog(@"%@", encodingsDictionary);
	}
}

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	lua = NULL;
	hasUpdateMethod = NO;
	objectsScheduledToRelease = [NSMutableArray new];
	delegateClassesScheduledToUnregisterFrom = [NSMutableArray new];
	signaturesCache = [[MPMapper alloc] initWithConverter: &sigConverter];
	scriptFileName = [aParams copy];
	setlocale(LC_NUMERIC, "C");
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
	[signaturesCache release];
	[scriptFileName release];
	[objectsScheduledToRelease release];
	[delegateClassesScheduledToUnregisterFrom release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	api = [anAPI retain];
}

- (void) start
{
	firstUpdate = YES;
	lua = luaL_newstate();
	if (!lua)
	{
		[[api log] add: critical withFormat: @"MPLuaSubject: Error creating lua context."];
		return;
	}
	REGISTER_LUA_STATE(lua);

	luaL_openlibs(lua);

	//Set alert function
	lua_pushcfunction(lua, lua_ALERT);
	lua_setfield(lua, LUA_GLOBALSINDEX, "_ALERT");

	//Register api, objectsScheduledToRelease, delegateClassesScheduledToUnregisterFrom, signaturesMapper
	id *apiExport = lua_newuserdata(lua, sizeof(id));
	*apiExport = api;
	lua_setfield(lua, LUA_REGISTRYINDEX, "api");

	id *objectsScheduledToReleaseExport = lua_newuserdata(lua, sizeof(id));
	*objectsScheduledToReleaseExport = objectsScheduledToRelease;
	lua_setfield(lua, LUA_REGISTRYINDEX, "objectsScheduledToRelease");

	id *delegateClassesScheduledToUnregisterFromExport = lua_newuserdata(lua, sizeof(id));
	*delegateClassesScheduledToUnregisterFromExport = delegateClassesScheduledToUnregisterFrom;
	lua_setfield(lua, LUA_REGISTRYINDEX, "delegateClassesScheduledToUnregisterFrom");

	id *signaturesMapperExport = lua_newuserdata(lua, sizeof(id));
	*signaturesMapperExport = signaturesCache;
	lua_setfield(lua, LUA_REGISTRYINDEX, "signaturesMapper");

	//Register error handler
	lua_pushcfunction(lua, luaErrorHandler);
	lua_setfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	
	//Register MPObjects
	lua_newuserdata(lua, 0);
	lua_createtable(lua, 0, 1);
	lua_pushcfunction(lua, luaMPObjectSystemMetaTable_index);
	lua_setfield(lua, -2, "__index");
	lua_setmetatable(lua, -2);
	lua_setfield(lua, LUA_GLOBALSINDEX, "MPObjects");

	//Register MPMethodAliasTable
	lua_createtable(lua, 0, 0);
	lua_setfield(lua, LUA_GLOBALSINDEX, "MPMethodAliasTable");

	//Register MPObject metatable
	lua_createtable(lua, 0, 1);
	int mtindex = lua_gettop(lua);

	lua_pushcfunction(lua, luaMPObjectMetaTable_index);
	lua_setfield(lua, mtindex, "__index");
	lua_pushcfunction(lua, luaMPObjectMetaTable_newindex);
	lua_setfield(lua, mtindex, "__newindex");
	lua_pushcfunction(lua, luaMPObjectMetaTable_eq);
	lua_setfield(lua, mtindex, "__eq");
	lua_pushcfunction(lua, luaMPObjectMetaTable_gc);
	lua_setfield(lua, mtindex, "__gc");

	lua_setfield(lua, LUA_REGISTRYINDEX, "MPObjectMetaTable");

	//Register MPMessageHandlers table
	lua_createtable(lua, 0, 0);
	lua_setfield(lua, LUA_GLOBALSINDEX, "MPMessageHandlers");

	//Register string constants
	#define REGISTER_LUA_STRINGCONST(c) \
		lua_pushstring(lua, #c);\
		lua_setfield(lua, LUA_GLOBALSINDEX, #c)

	REGISTER_LUA_STRINGCONST(info);
	REGISTER_LUA_STRINGCONST(notice);
	REGISTER_LUA_STRINGCONST(warning);
	REGISTER_LUA_STRINGCONST(error);
	REGISTER_LUA_STRINGCONST(critical);
	REGISTER_LUA_STRINGCONST(alert);
	#undef REGISTER_LUA_STRINGCONST
	
	//Register plainEngine api
	#define REGISTER_LUA_FUNCTION(f) lua_register(lua, #f, lua##f);
	REGISTER_LUA_FUNCTION(MPLog);
	REGISTER_LUA_FUNCTION(MPPostMessage);
	REGISTER_LUA_FUNCTION(MPYield);
	REGISTER_LUA_FUNCTION(MPGetMilliseconds);
	REGISTER_LUA_FUNCTION(MPObjectByName);
	REGISTER_LUA_FUNCTION(MPObjectByHandle);
	REGISTER_LUA_FUNCTION(MPNewObject);
	REGISTER_LUA_FUNCTION(MPCreateObject);
	REGISTER_LUA_FUNCTION(MPGetAllObjects);
	REGISTER_LUA_FUNCTION(MPGetObjectsByFeature);
	REGISTER_LUA_FUNCTION(MPRegisterDelegateClass);
	REGISTER_LUA_FUNCTION(MPRegisterDelegateClassForFeature);
	#undef REGISTER_LUA_FUNCTION

	if (luaL_dofile(lua, [scriptFileName UTF8String]))
	{
		[[api log] add: error withFormat: @"MPLuaSubject: Error loading script"];
		return;
	}

	//Check for update method
	lua_getfield(lua, LUA_GLOBALSINDEX, "update");
	hasUpdateMethod = !lua_isnil(lua, -1) && lua_isfunction(lua, -1);
	lua_pop(lua, -1);


	//Running initialization function
	lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	lua_getfield(lua, LUA_GLOBALSINDEX, "init");
	if ((!lua_isnil(lua, -1)) && (lua_isfunction(lua, -1)))
	{
		lua_pcall(lua, 0, 0, -2);
	}
	else
	{
		lua_pop(lua, 1);
	}
	lua_pop(lua, 1); //pop errorHandler
}

- (void) stop
{
	UNREGISTER_LUA_STATE(lua);
	NSUInteger i, count;
	count = [delegateClassesScheduledToUnregisterFrom count];
	for (i=0; i<count; ++i)
	{
		[[api getObjectSystem] unregisterDelegateFromAll: [delegateClassesScheduledToUnregisterFrom objectAtIndex: i]];
	}
	[delegateClassesScheduledToUnregisterFrom removeAllObjects];
	if (lua)
	{
		lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
		lua_getfield(lua, LUA_GLOBALSINDEX, "stop");
		if ((!lua_isnil(lua, -1)) && (lua_isfunction(lua, -1)))
		{
			lua_pcall(lua, 0, 0, -2);
		}
		else
		{
			lua_pop(lua, 1);
		}
		lua_pop(lua, 1); //pop errorHandler

		lua_close(lua);
		[[api log] add: notice withFormat: @"MPLuaSubject: Lua state closed"];
	}
	[objectsScheduledToRelease removeAllObjects];
	lua = NULL;
}

- (void) update
{
	if (!lua)
	{
		return;
	}
	if (firstUpdate)
	{
		firstUpdate = NO;
		lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
		lua_getfield(lua, LUA_GLOBALSINDEX, "start");
		if ((!lua_isnil(lua, -1)) && (lua_isfunction(lua, -1)))
		{
			lua_pcall(lua, 0, 0, -2);
		}
		else
		{
			lua_pop(lua, 1);
		}
		lua_pop(lua, 1); //pop errorHandler
	}
	if (hasUpdateMethod)
	{
		LUA_LOCK;
		lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
		lua_getfield(lua, LUA_GLOBALSINDEX, "update");
		lua_pcall(lua, 0, 0, -2);
		lua_pop(lua, 1); //pop errorHandler
		LUA_UNLOCK;
	}
}

MP_HANDLER_OF_ANY_MESSAGE
{
	if (!lua)
	{
		return;
	}

	LUA_LOCK;

	lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	int errorHandler = lua_gettop(lua);

	lua_getfield(lua, LUA_GLOBALSINDEX, [[NSString stringWithFormat: @"MPHandlerOfAnyMessage", MP_MESSAGE_NAME] UTF8String]);
	if (!lua_isnil(lua, -1))
	{
		lua_pushstring(lua, [MP_MESSAGE_NAME UTF8String]);
		NSUInteger count = [MP_MESSAGE_DATA count];
		lua_createtable(lua, 0, count);
		int msgdata = lua_gettop(lua);
		if (count)
		{
			NSEnumerator *enumer;
			enumer = [MP_MESSAGE_DATA keyEnumerator];
			NSString *key;
			while ((key = [enumer nextObject]) != nil)
			{
				lua_pushstring(lua, [[MP_MESSAGE_DATA objectForKey: key] UTF8String]);
				lua_setfield(lua, msgdata, [key UTF8String]);
			}
		}
		lua_pcall(lua, 2, 0, errorHandler);
	}
	else
	{
		lua_pop(lua, 1);
	}

	lua_getfield(lua, LUA_GLOBALSINDEX, "MPMessageHandlers");
	lua_getfield(lua, -1, [MP_MESSAGE_NAME UTF8String]);
	if (!lua_isnil(lua, -1))
	{
		pushLuaTableFromStringDictionary(lua, MP_MESSAGE_DATA);
		lua_pcall(lua, 1, 0, errorHandler);
	}
	else
	{
		lua_pop(lua, 1);
	}
	lua_pop(lua, 2); //MPMessageHandlers and errorHandler
	LUA_UNLOCK;
}

@end


