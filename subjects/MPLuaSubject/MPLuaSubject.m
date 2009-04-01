#import <MPCore.h>
#import <MPLuaSubject.h>
#import <MPLuaExports.h>
#import <MPLuaHelpers.h>

#import <locale.h>

@implementation MPLuaSubject

- initWithString: (NSString *)aParams
{
	[super init];
	api = nil;
	lua = NULL;
	hasUpdateMethod = NO;
	objectsScheduledToRelease = [NSMutableArray new];
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
	[scriptFileName release];
	[objectsScheduledToRelease release];
	[super dealloc];
}

- (void) receiveAPI: (id<MPAPI>)anAPI
{
	api = [anAPI retain];
}

- (void) start
{
	lua = luaL_newstate();
	if (!lua)
	{
		[[api log] add: critical withFormat: @"MPLuaSubject: Error creating lua context."];
		return;
	}

	luaL_openlibs(lua);

	//Set alert function
	lua_pushcfunction(lua, lua_ALERT);
	lua_setfield(lua, LUA_GLOBALSINDEX, "_ALERT");
	
	if (luaL_dofile(lua, [scriptFileName UTF8String]))
	{
		[[api log] add: error withFormat: @"MPLuaSubject: Error loading script"];
		return;
	}

	//Register api and objectsScheduledToRelease
	id *apiExport = lua_newuserdata(lua, sizeof(id));
	*apiExport = api;
	lua_setfield(lua, LUA_REGISTRYINDEX, "api");

	id *objectsScheduledToReleaseExport = lua_newuserdata(lua, sizeof(id));
	*objectsScheduledToReleaseExport = objectsScheduledToRelease;
	lua_setfield(lua, LUA_REGISTRYINDEX, "objectsScheduledToRelease");

	//Check for update method
	lua_getfield(lua, LUA_GLOBALSINDEX, "update");
	hasUpdateMethod = !lua_isnil(lua, -1) && lua_isfunction(lua, -1);
	lua_pop(lua, -1);

	//Register MPObjs
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
	REGISTER_LUA_FUNCTION(MPObjectByName);
	REGISTER_LUA_FUNCTION(MPNewObject);
	REGISTER_LUA_FUNCTION(MPCreateObject);
	REGISTER_LUA_FUNCTION(MPGetAllObjects);
	REGISTER_LUA_FUNCTION(MPGetObjectsByFeature);
	#undef REGISTER_LUA_FUNCTION

	//Running initialization function
	lua_getfield(lua, LUA_GLOBALSINDEX, "start");
	if ((!lua_isnil(lua, -1)) && (lua_isfunction(lua, -1)))
	{
		lua_call(lua, 0, 0);
	}
	else
	{
		lua_pop(lua, 1);
	}
}

- (void) stop
{
	if (lua)
	{
		lua_getfield(lua, LUA_GLOBALSINDEX, "stop");
		if ((!lua_isnil(lua, -1)) && (lua_isfunction(lua, -1)))
		{
			lua_call(lua, 0, 0);
		}
		else
		{
			lua_pop(lua, 1);
		}

		lua_close(lua);
	}
	[objectsScheduledToRelease removeAllObjects];
	lua = NULL;
}

- (void) update
{
	if (hasUpdateMethod)
	{
		lua_getfield(lua, LUA_GLOBALSINDEX, "update");
		lua_call(lua, 0, 0);
	}
}

MP_HANDLER_OF_ANY_MESSAGE
{
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
		lua_call(lua, 2, 0);
	}
	else
	{
		lua_pop(lua, 1);
	}


	lua_getfield(lua, LUA_GLOBALSINDEX, [[NSString stringWithFormat: @"MPHandlerOfMessage_%@", MP_MESSAGE_NAME] UTF8String]);
	if (!lua_isnil(lua, -1))
	{
		pushLuaTableFromStringDictionary(lua, MP_MESSAGE_DATA);
		lua_call(lua, 1, 0);
	}
	else
	{
		lua_pop(lua, 1);
	}
}

@end


