#import <Foundation/Foundation.h>

#import <MPLuaExports.h>
#import <MPLuaHelpers.h>
#import <MPCore.h>

int luaMPObjectSystemMetaTable_index(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	const char *objectName = lua_tostring(lua, -1);
	lua_pop(lua, 2);
	pushMPObject(lua, [[api getObjectSystem] getObjectByName: [NSString stringWithUTF8String: objectName]], YES);
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_getName(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	lua_pushstring(lua, [[obj getName] UTF8String]);
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_getHandle(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	lua_pushnumber(lua, [[obj getHandle] doubleValue]);
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_hasFeature(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	const char *featureName = lua_tostring(lua, -1);
	lua_pop(lua, 1);
	lua_pushboolean(lua, [obj hasFeature: [NSString stringWithUTF8String: featureName]]);
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_copyWithName(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	const char *newName = lua_tostring(lua, -1);
	id newobj = [obj copyWithName: [NSString stringWithUTF8String: newName]];
	lua_pop(lua, 1);
	pushMPObject(lua, newobj, YES);
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_copy(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	id newobj = [obj copy];
	pushMPObject(lua, newobj, YES);
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_getAllFeatures(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	NSDictionary *features = [obj getAllFeatures];
	
	lua_createtable(lua, 0, [features count]);
	int featuresTable = lua_gettop(lua);
	
	NSEnumerator *enumer = [features keyEnumerator];
	NSString *key;
	while ((key = [enumer nextObject]) != nil)
	{
		lua_pushstring(lua, [[[features objectForKey: key] stringValue] UTF8String]);
		lua_setfield(lua, featuresTable, [key UTF8String]);
	}
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_getFeatureData(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);

	const char *featureName = lua_tostring(lua, -1);
	lua_pushstring(lua, [[[obj getFeatureData: [NSString stringWithUTF8String: featureName]] stringValue] UTF8String]);
	LUA_UNLOCK;
	return 1;
}

int luaMPObject_setFeature(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	int argcount = lua_gettop(lua);

	NSString *featureName = [NSString stringWithUTF8String: lua_tostring(lua, -argcount)];
	id<MPVariant> data = [MPVariant variantWithString: @""];
	id userInfo = [MPMutableDictionary new];

	if (argcount >= 2)
	{
		const char *value = lua_tostring(lua, -argcount+1);
		data = [MPVariant variantWithString: [NSString stringWithUTF8String: value]];
	}
	if (argcount >= 3)
	{
		int userInfoIndex = lua_gettop(lua);

		lua_pushnil(lua);
		while (lua_next(lua, userInfoIndex) != 0)
		{
			[userInfo setObject: [NSString stringWithUTF8String: lua_tostring(lua, -1)]
					  forKey: [NSString stringWithUTF8String: lua_tostring(lua, -2)]];
			lua_pop(lua, 1); //remove value, keep key for next iteration
		}
	}

	lua_pop(lua, argcount);

	[obj setFeature: featureName toValue: data userInfo: userInfo];
	[userInfo release];
	LUA_UNLOCK;
	return 0;
}

int luaMPObject_removeFeature(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	int argcount = lua_gettop(lua);

	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);

	NSString *featureName = [NSString stringWithUTF8String: lua_tostring(lua, -argcount)];
	id userInfo = [MPMutableDictionary new];

	if (argcount == 2)
	{
		int userInfoIndex = lua_gettop(lua);

		lua_pushnil(lua);
		while (lua_next(lua, userInfoIndex) != 0)
		{
			[userInfo setObject: [NSString stringWithUTF8String: lua_tostring(lua, -1)]
					  forKey: [NSString stringWithUTF8String: lua_tostring(lua, -2)]];
			lua_pop(lua, 1); //remove value, keep key for next iteration
		}
	}

	lua_pop(lua, argcount);

	[obj removeFeature: featureName userInfo: userInfo];
	[userInfo release];
	LUA_UNLOCK;
	return 0;
}


int luaMPObject_respondsTo(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	id obj = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	const char *selName = lua_tostring(lua, -1);
	lua_pop(lua, 1);
	lua_pushboolean(lua, [obj respondsToSelector: sel_registerName(selName)]);
	LUA_UNLOCK;
	return 1;
}


int luaMPObject_dcall(lua_State *lua)
{
	LUA_LOCK;
	lua_remove(lua, 1); //remove unnecessary 'self'
	int luaargcount = lua_gettop(lua);

	id object = getMPObjectFromStack(lua, lua_upvalueindex(1), NULL);
	const char *methodName = lua_tostring(lua, lua_upvalueindex(2));
	LOAD_API;

	release_bunch rbunch = relbunch_create();
	SEL methodSelector;
	NSMethodSignature *sig;

	getSelectorAndMethodSignature(object, methodName, &methodSelector, &sig);

	if (!sig)
	{
		[[api log] add: warning withFormat: @"MPLuaSubject: (DCaller) No delegate of object '%@' to respond to selector \"%s\".", object, methodName];
		relbunch_release(rbunch);
		lua_pushnil(lua);
		LUA_UNLOCK_AND_RETURN(1);
	}

	NSInvocation *inv = [[NSInvocation invocationWithMethodSignature: sig] retain];
	[inv setSelector: methodSelector];
	[inv setTarget: object];

	unsigned argcount = [sig numberOfArguments]-2;
	if (argcount > luaargcount)
	{
		[[api log] add: error withFormat: @"MPLuaSubject: (DCaller) Not enough arguments;"];
		relbunch_release(rbunch);

		LUA_UNLOCK_AND_RETURN(1);
	}
	if (argcount < luaargcount)
	{
		[[api log] add: warning withFormat: @"MPConsoleInputDelegateCallerSubject: Too many arguments, redundant ones had been omitted;"];
	}

	unsigned i;
	for (i=2; i<argcount+2; ++i)
	{
		//lua index: i-argcount-2
		unsigned int size;
		NSGetSizeAndAlignment([sig getArgumentTypeAtIndex: i], &size, NULL);
		void *arg = malloc(size);
		relbunch_add_pointer(rbunch, arg);
		BOOL found=NO;
		#define DO_TYPE_CHECK(type, luameth)\
			if (!found && (strcmp([sig getArgumentTypeAtIndex: i], @encode(type)) == 0))\
			{\
				type t = luameth(lua, i-argcount-2);\
				memcpy(arg, &t, sizeof(t));\
				found = YES;\
			}

		DO_TYPE_CHECK(double,				lua_tonumber);
		DO_TYPE_CHECK(long long,			lua_tonumber);
		DO_TYPE_CHECK(int,					lua_tonumber);
		DO_TYPE_CHECK(unsigned int,			lua_tonumber);
		DO_TYPE_CHECK(float,				lua_tonumber);
		DO_TYPE_CHECK(long,					lua_tonumber);
		DO_TYPE_CHECK(unsigned long,		lua_tonumber);
		DO_TYPE_CHECK(unsigned long long,	lua_tonumber);
		DO_TYPE_CHECK(char,					lua_tonumber);
		DO_TYPE_CHECK(unsigned char,		lua_tonumber);
		DO_TYPE_CHECK(short,				lua_tonumber);
		DO_TYPE_CHECK(unsigned short,		lua_tonumber);
		#undef DO_TYPE_CHECK

		if (!found)
		{
			[[api log] add: error withFormat: @"MPLuaSubject: (DCaller) type \'%s\' not supported", [sig getArgumentTypeAtIndex: i]];
			relbunch_release(rbunch);
			lua_pushnil(lua);

			LUA_UNLOCK_AND_RETURN(1);
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

	const char *type = [sig methodReturnType];
	int returnCount = 1;

	#define ELSEIF_CHECK_TYPE(tname, fmt)\
	else if (strcmp(type, @encode(tname)) == 0)\
	{\
		lua_pushstring(lua, [[NSString stringWithFormat: fmt, *(tname *)retbuffer] UTF8String]);\
	}

	if (strcmp(type, @encode(void)) == 0)
	{
		returnCount = 0;
	}
	ELSEIF_CHECK_TYPE(double,				@"%lf")
	ELSEIF_CHECK_TYPE(float,				@"%f")
	ELSEIF_CHECK_TYPE(long long,			@"%lld")
	ELSEIF_CHECK_TYPE(int,					@"%d")
	ELSEIF_CHECK_TYPE(unsigned int,			@"%u")
	ELSEIF_CHECK_TYPE(long,					@"%ld")
	ELSEIF_CHECK_TYPE(unsigned long,		@"%lu")
	ELSEIF_CHECK_TYPE(unsigned long long,	@"%llu")
	ELSEIF_CHECK_TYPE(char,					@"%c")
	ELSEIF_CHECK_TYPE(unsigned char,		@"%u")
	ELSEIF_CHECK_TYPE(short,				@"%d")
	ELSEIF_CHECK_TYPE(unsigned short,		@"%u")
	else
	{
		lua_pushnil(lua);
		[[api log] add: error withFormat: @"MPLuaSubject: (DCaller) cannot convert to string type '%s'", type];
	}

	#undef CHECK_TYPE

	relbunch_release(rbunch);

	LUA_UNLOCK_AND_RETURN(returnCount);
}

int luaMPObjectMetaTable_index(lua_State *lua)
{
	LUA_LOCK;
	const char *name = lua_tostring(lua, -1);
	lua_getfield(lua, LUA_GLOBALSINDEX, "MPMethodAliasTable");
	lua_getfield(lua, -1, name);
	lua_remove(lua, -2); //remove alias table from stack
	if (lua_isnil(lua, -1))
	{
		lua_pop(lua, 1); //return to old name
	}
	else
	{
		lua_remove(lua, -2); //remove old name
		name = lua_tostring(lua, -1);
	}
	#define IF_CORRESPONDS_PUSHFUNCTION(fname) \
	if (strcmp(name, #fname) == 0)\
	{\
		lua_pushcclosure(lua, luaMPObject_##fname, 2);\
	}


	IF_CORRESPONDS_PUSHFUNCTION(getName)
	else IF_CORRESPONDS_PUSHFUNCTION(getHandle)
	else IF_CORRESPONDS_PUSHFUNCTION(hasFeature)
	else IF_CORRESPONDS_PUSHFUNCTION(copy)
	else IF_CORRESPONDS_PUSHFUNCTION(copyWithName)
	else IF_CORRESPONDS_PUSHFUNCTION(getAllFeatures)
	else IF_CORRESPONDS_PUSHFUNCTION(getFeatureData)
	else IF_CORRESPONDS_PUSHFUNCTION(setFeature)
	else IF_CORRESPONDS_PUSHFUNCTION(removeFeature)
	else IF_CORRESPONDS_PUSHFUNCTION(respondsTo)
	else
	{
		lua_pushcclosure(lua, luaMPObject_dcall, 2);
	}
	#undef IF_CORRESPONDS_PUSHFUNCTION
	LUA_UNLOCK;
	return 1;
}

int luaMPObjectMetaTable_newindex(lua_State *lua)
{
	LUA_LOCK;
	id object = getMPObjectFromStack(lua, -3, NULL);

	const char *featureName = lua_tostring(lua, -2);
	const char *featureValue = lua_tostring(lua, -1);
	[object setFeature: [NSString stringWithUTF8String: featureName]
			   toValue: [MPVariant variantWithString: [NSString stringWithUTF8String: featureValue]]];
	lua_pop(lua, 3);
	LUA_UNLOCK;
	return 0;
}

int luaMPObjectMetaTable_eq(lua_State *lua)
{
	LUA_LOCK;
	id object1 = getMPObjectFromStack(lua, -1, NULL);
	id object2 = getMPObjectFromStack(lua, -2, NULL);

	lua_pop(lua, 2);
	lua_pushboolean(lua, [object1 isEqual: object2]);
	LUA_UNLOCK;
	return 1;
}

int luaMPObjectMetaTable_gc(lua_State *lua)
{
	LUA_LOCK;
	BOOL isRetained;
	id object = getMPObjectFromStack(lua, -1, &isRetained);
	if (isRetained)
	{
		[object release];
	}
	lua_pop(lua, 1);
	LUA_UNLOCK;
	return 0;
}

