#import <Foundation/Foundation.h>

#import <MPLuaExports.h>
#import <MPLuaHelpers.h>
#import <MPCore.h>

int lua_ALERT(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	const char *msg = lua_tostring(lua, -1);
	lua_pop(lua, -1);
	[[api log] add: critical withFormat: @"%s", msg];
	LUA_UNLOCK;
	return 0;
}

int luaErrorHandler(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	const char *msg = lua_tostring(lua, -1);
	[[api log] add: error withFormat: @"MPLuaSubject: Lua error occured with message: \"%s\"", msg];
	lua_pop(lua, 1);
	LUA_UNLOCK;
	return 0;
}

int luaMPLog(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;

	if (lua_gettop(lua) == 1)
	{
		const char *message = lua_tostring(lua, -1);
		[[api log] add: notice withFormat: @"%s", message];

		lua_pop(lua, 1);
	}
	else
	{
		const char *level = lua_tostring(lua, -2);
		mplog_level loglev = user;
	
		#define CHECK_LEVEL(lev) if (strcmp(level, #lev) == 0) loglev = lev
		CHECK_LEVEL(alert);
		CHECK_LEVEL(critical);
		CHECK_LEVEL(error);
		CHECK_LEVEL(warning);
		CHECK_LEVEL(notice);
		CHECK_LEVEL(info);
		#undef CHECK_LEVEL
	
		const char *message = lua_tostring(lua, -1);
		[[api log] add: loglev withFormat: @"%s", message];
	
		lua_pop(lua, 2);
	}
	LUA_UNLOCK;
	return 0;
}

int luaMPPostMessage(lua_State *lua)
{
	LUA_LOCK;
	if (lua_gettop(lua) == 1)
	{
		const char *message = lua_tostring(lua, -1);
		lua_pop(lua, 1);
	
		LOAD_API;
	
		[api postMessageWithName: [NSString stringWithUTF8String: message]];

	}
	else
	{
		const char *message = lua_tostring(lua, -2);
		int tableindex = lua_gettop(lua);

		MPMutableDictionary *params = [MPMutableDictionary new];
		lua_pushnil(lua);
		while (lua_next(lua, tableindex) != 0)
		{
			[params setObject: [NSString stringWithUTF8String: lua_tostring(lua, -1)]
					   forKey: [NSString stringWithUTF8String: lua_tostring(lua, -2)]];
			lua_pop(lua, 1); //remove value, keep key for next iteration
		}

		lua_pop(lua, 2);

		LOAD_API;

		[api postMessageWithName: [NSString stringWithUTF8String: message] userInfo: params];
		[params release];

	}
	LUA_UNLOCK;
	return 0;
}

int luaMPYield(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	[api yield];
	LUA_UNLOCK;
	return 0;
}

int luaMPGetMilliseconds(lua_State *lua)
{
	LUA_LOCK;
	lua_pushnumber(lua, getMilliseconds());
	LUA_UNLOCK;
	return 1;
}

int luaMPObjectByName(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	id object = [[api getObjectSystem] getObjectByName: [NSString stringWithUTF8String: lua_tostring(lua, -1)]];
	lua_pop(lua, 1);
	pushMPObject(lua, object);
	LUA_UNLOCK;
	return 1;
}

int luaMPObjectByHandle(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	id object = [[api getObjectSystem] getObjectByHandle: [[[NSNumber alloc] INIT_WITH_MPHANDLE: lua_tointeger(lua, -1)] autorelease]];
	lua_pop(lua, 1);
	pushMPObject(lua, object);
	LUA_UNLOCK;
	return 1;
}



int luaMPNewObject(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	id object = [[api getObjectSystem] newObjectWithName: [NSString stringWithUTF8String: lua_tostring(lua, -1)]];
	lua_pop(lua, 1);
	pushMPObject(lua, object);
	LUA_UNLOCK;
	return 1;
}

int luaMPCreateObject(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	id object = [[api getObjectSystem] newObjectWithName: [NSString stringWithUTF8String: lua_tostring(lua, -1)]];

	lua_getfield(lua, LUA_REGISTRYINDEX, "objectsScheduledToRelease");
	NSMutableArray *objectsScheduledToRelease = *(id *)(lua_touserdata(lua, -1));
	lua_pop(lua, 2);

	[objectsScheduledToRelease addObject: object];
	[object release];

	pushMPObject(lua, object);
	LUA_UNLOCK;
	return 1;
}

void pushArrayOfObjects(lua_State *lua, NSArray *array)
{
	LUA_LOCK;
	NSUInteger i, count = [array count];
	lua_createtable(lua, count, 0);
	int arrayIndex = lua_gettop(lua);

	for (i=0; i<count; ++i)
	{
		pushMPObject(lua, [array objectAtIndex: i]);
		lua_rawseti(lua, arrayIndex, i+1);
	}
	LUA_UNLOCK;
}

int luaMPGetAllObjects(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	pushArrayOfObjects(lua, [[api getObjectSystem] getAllObjects]);
	LUA_UNLOCK;
	return 1;
}

int luaMPGetObjectsByFeature(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	const char *featureName = lua_tostring(lua, -1);
	lua_pop(lua, 1);
	pushArrayOfObjects(lua, [[api getObjectSystem] getObjectsByFeature: [NSString stringWithUTF8String: featureName]]);
	LUA_UNLOCK;
	return 1;
}


