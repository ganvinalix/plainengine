#import <Foundation/Foundation.h>

#import <MPLuaExports.h>
#import <MPLuaHelpers.h>
#import <MPCore.h>

#import <math.h>

typedef struct
{
	char *name;
} luaDelegateStruct;

typedef struct
{
	char *name;
	lua_State *lua;
} luaDelegateClassInfo;

DECLARE_INIT_FUNC(luaDelegateInit)
{
	luaDelegateClassInfo *clInfo = classInfo;
	lua_State *lua = clInfo->lua;
	LUA_LOCK;
	int test = lua_gettop(lua); //TODO: Remove later

	lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	int errorHandler = lua_gettop(lua);

	LOAD_API;
	static NSUInteger delegateCounter=1;	
	char *delegateTableName;
	unsigned size = log(delegateCounter)/log(10) + 2 //digits count
						+ 5;
	delegateTableName = malloc(size*sizeof(char));
	delegateTableName[size-1] = 0;
	sprintf(delegateTableName, "del_%u", ++delegateCounter);

	FIELD_FROM_STRUCT(luaDelegateStruct, name) = delegateTableName;

	lua_getfield(lua, LUA_REGISTRYINDEX, clInfo->name);
	lua_getfield(lua, -1, "newDelegateWithObject");
	if (!lua_isnil(lua, -1))
	{
		lua_getfield(lua, LUA_REGISTRYINDEX, clInfo->name);
		pushMPObject(lua, [[api getObjectSystem] getObjectByHandle: [[[NSNumber alloc] INIT_WITH_MPHANDLE: oHandle] autorelease]]);
		lua_pcall(lua, 2, 1, errorHandler);
		lua_setfield(lua, LUA_REGISTRYINDEX, delegateTableName);
	}
	else
	{
		lua_pop(lua, 1);
		lua_getfield(lua, -1, "new");
		if (!lua_isnil(lua, -1))
		{
			lua_getfield(lua, LUA_REGISTRYINDEX, clInfo->name);
			lua_pcall(lua, 1, 1, errorHandler);
			lua_setfield(lua, LUA_REGISTRYINDEX, delegateTableName);
		}
		else
		{
			[api add: error withFormat: @"No delegate creator at class '%s'", clInfo->name];
			lua_createtable(lua, 0, 0);
			lua_setfield(lua, LUA_REGISTRYINDEX, delegateTableName);
		}
	}
	lua_pop(lua, 2);
	NSCAssert1(test == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test); //TODO: Remove later
	LUA_UNLOCK;
}

DECLARE_CLEAN_FUNC(luaDelegateClean)
{
	luaDelegateClassInfo *clInfo = classInfo;
	lua_State *lua = clInfo->lua;
	LUA_LOCK;

	lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	int errorHandler = lua_gettop(lua);

	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name));
	lua_getfield(lua, -1, "dealloc");
	if (!lua_isnil(lua, -1))
	{
		lua_pcall(lua, 0, 0, errorHandler);
	}
	else
	{
		lua_pop(lua, 1);
	}
	lua_pop(lua, 2);

	lua_pushnil(lua);
	lua_setfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name));
	free(FIELD_FROM_STRUCT(luaDelegateStruct, name));
	LUA_UNLOCK;
}

DECLARE_SET_FEATURE_FUNC(luaDelegateSetFeature)
{
	luaDelegateClassInfo *clInfo = classInfo;
	lua_State *lua = clInfo->lua;
	LUA_LOCK;
	int test = lua_gettop(lua); //TODO: Remove later

	lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	int errorHandler = lua_gettop(lua);

	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name));
	lua_getfield(lua, -1, "setFeature");
	if (lua_isnil(lua, -1))
	{
		lua_pop(lua, 3);
		LUA_UNLOCK;
		return;
	}
	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name)); //self
	lua_pushstring(lua, featureName);
	lua_pushstring(lua, featureValue);
	pushLuaTableFromStringDictionary(lua, [[[MPDictionary alloc] initWithCDictionary: userDict] autorelease]);
	lua_pcall(lua, 4, 0, errorHandler);
	lua_pop(lua, 2);
	NSCAssert1(test == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test); //TODO: Remove later
	LUA_UNLOCK;
}

DECLARE_REMOVE_FEATURE_FUNC(luaDelegateRemoveFeature)
{
	luaDelegateClassInfo *clInfo = classInfo;
	lua_State *lua = clInfo->lua;
	LUA_LOCK;
	int test = lua_gettop(lua); //TODO: Remove later

	lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	int errorHandler = lua_gettop(lua);

	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name));
	lua_getfield(lua, -1, "removeFeature");
	if (lua_isnil(lua, -1))
	{
		lua_pop(lua, 3);
		return;
	}
	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name)); //self
	lua_pushstring(lua, featureName);
	pushLuaTableFromStringDictionary(lua, [[[MPDictionary alloc] initWithCDictionary: userDict] autorelease]);
	lua_pcall(lua, 3, 0, errorHandler);
	lua_pop(lua, 2);
	NSCAssert1(test == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test); //TODO: Remove later
	LUA_UNLOCK;
}

NSMethodSignature *getMethodSignatureAndPushFunction(lua_State *lua, const char *funcname)
{
	LUA_LOCK;
	int test = lua_gettop(lua); //TODO: Remove later
	NSMethodSignature *sig;
	lua_getfield(lua, -1, "signatures");
	if (lua_isnil(lua, -1))
	{
		LUA_UNLOCK;
		return nil; //nil value is already on stack
	}

	NSMutableString *parsedfuncname = [NSMutableString string];
	NSString *searchedfuncname = [NSString stringWithUTF8String: funcname];

	MPMapper *signaturesMapper;
	lua_getfield(lua, LUA_REGISTRYINDEX, "signaturesMapper");
	signaturesMapper = *(id *)lua_touserdata(lua, -1);
	lua_pop(lua, 1);

	int signaturesIndex = lua_gettop(lua);
	lua_pushnil(lua);

	while (lua_next(lua, signaturesIndex) != 0)
	{
		sig = parseSignature(signaturesMapper, [NSString stringWithUTF8String: lua_tostring(lua, -1)], parsedfuncname);
		lua_pop(lua, 1); //remove value, keep key for next iteration
		if ([parsedfuncname isEqualToString: searchedfuncname])
		{
			lua_pop(lua, 2);
			stringReplace(parsedfuncname, @":", @"");
			lua_getfield(lua, -1, [parsedfuncname UTF8String]);

			NSCAssert1(test+1 == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test-1); //TODO: Remove later
			LUA_UNLOCK;
			return sig;
		}
	}

	lua_pop(lua, 1);

	lua_pushnil(lua);
	NSCAssert1(test+1 == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test-1); //TODO: Remove later
	LUA_UNLOCK;
	return nil;

}

DECLARE_DELEGATE_METHODSIGNATUREGETTER(luaDelegateMethodSignatureGetter)
{
	luaDelegateClassInfo *clInfo = classInfo;
	lua_State *lua = clInfo->lua;
	LUA_LOCK;
	int test = lua_gettop(lua); //TODO: Remove later
	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name));
	NSMethodSignature *sig = getMethodSignatureAndPushFunction(lua, methodName);
	lua_pop(lua, 2);
	NSCAssert1(test == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test); //TODO: Remove later
	LUA_UNLOCK;
	return sig;
}

DECLARE_METHOD(luaDelegateCallMethod)
{
	luaDelegateClassInfo *clInfo = classInfo;
	lua_State *lua = clInfo->lua;
	LUA_LOCK;
	int test = lua_gettop(lua); //TODO: Remove later

	lua_getfield(lua, LUA_REGISTRYINDEX, "errorHandler");
	int errorHandler = lua_gettop(lua);

	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name));

	NSCAssert1(test+2 == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test-2); //TODO: Remove later

	NSMethodSignature *sig = getMethodSignatureAndPushFunction(lua, methodName);
	if (lua_isnil(lua, lua_gettop(lua)))
	{
		lua_pop(lua, 3); //errorHandler, delegateTable, nil
		LUA_UNLOCK;
		return;
	}

	NSCAssert1(test+3 == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test-3); //TODO: Remove later

	lua_getfield(lua, LUA_REGISTRYINDEX, FIELD_FROM_STRUCT(luaDelegateStruct, name)); //self

	FOR_EACH_PARAM(i, [sig numberOfArguments]-2, param)
	{
		BOOL found=NO;
		#define DO_TYPE_CHECK(type, luameth)\
			if (!found && (strcmp([sig getArgumentTypeAtIndex: i+2], @encode(type)) == 0))\
			{\
				type t = *(type *)params[i];\
				luameth(lua, t);\
				found = YES;\
			}

		DO_TYPE_CHECK(double,				lua_pushnumber);
		DO_TYPE_CHECK(float,				lua_pushnumber);
		DO_TYPE_CHECK(long,					lua_pushnumber);
		DO_TYPE_CHECK(unsigned long,		lua_pushnumber);
		DO_TYPE_CHECK(long long,			lua_pushnumber);
		DO_TYPE_CHECK(unsigned long long,	lua_pushnumber);
		DO_TYPE_CHECK(char,					lua_pushnumber);
		DO_TYPE_CHECK(unsigned char,		lua_pushnumber);
		DO_TYPE_CHECK(short,				lua_pushnumber);
		DO_TYPE_CHECK(unsigned short,		lua_pushnumber);
		DO_TYPE_CHECK(int,					lua_pushnumber);
		DO_TYPE_CHECK(unsigned int,			lua_pushnumber);
		#undef DO_TYPE_CHECK
		if (!found)
		{
			LOAD_API;
			[[api log] add: error withFormat: @"MPLuaSubject: (DClass) type \'%s\' not supported", [sig getArgumentTypeAtIndex: i+2]];
			lua_pushnil(lua);
		}

	}

	int returnCount = strcmp([sig methodReturnType], @encode(void)) == 0 ? 0 : 1;

	lua_pcall(lua, [sig numberOfArguments]-1, returnCount, errorHandler);

	if (returnCount)
	{
		BOOL found=NO;
		#define DO_TYPE_CHECK(type, luameth)\
			if (!found && (strcmp([sig methodReturnType], @encode(type)) == 0))\
			{\
				type t = luameth(lua, -1);\
				SET_RESULT_VALUE(type, t);\
				found = YES;\
			}

		DO_TYPE_CHECK(double,				lua_tonumber);
		DO_TYPE_CHECK(float,				lua_tonumber);
		DO_TYPE_CHECK(long,					lua_tonumber);
		DO_TYPE_CHECK(unsigned long,		lua_tonumber);
		DO_TYPE_CHECK(long long,			lua_tonumber);
		DO_TYPE_CHECK(unsigned long long,	lua_tonumber);
		DO_TYPE_CHECK(char,					lua_tonumber);
		DO_TYPE_CHECK(unsigned char,		lua_tonumber);
		DO_TYPE_CHECK(short,				lua_tonumber);
		DO_TYPE_CHECK(unsigned short,		lua_tonumber);
		DO_TYPE_CHECK(int,					lua_tonumber);
		DO_TYPE_CHECK(unsigned int,			lua_tonumber);
		#undef DO_TYPE_CHECK

		if (!found)
		{
			LOAD_API;
			[[api log] add: error withFormat: @"MPLuaSubject: (DClass) return type \'%s\' not supported", [sig methodReturnType]];
		}

		lua_pop(lua, 1);

	}


	lua_pop(lua, 2); //errorHandler and delegate table

	NSCAssert1(test == lua_gettop(lua), @"Lua stack debalanced - %d", lua_gettop(lua)-test); //TODO: Remove later
	LUA_UNLOCK;
}


MPUniversalDelegateClassObject *getClassObjectFromTop(lua_State *lua)
{
	LUA_LOCK;
	static NSUInteger delegateClassCounter=1;	
	char *className;
	unsigned size = log(delegateClassCounter)/log(10) + 2 //digits count
						+ 5;
	className = malloc(size*sizeof(char));
	className[size-1] = 0;
	sprintf(className, "dcl_%u", ++delegateClassCounter);
	lua_setfield(lua, LUA_REGISTRYINDEX, className); //class table to registry
	MPUniversalDelegateClassObject *delegateClassObject;

	luaDelegateClassInfo *classInfo;
	classInfo = malloc(sizeof(luaDelegateClassInfo));
	classInfo->name = className;
	classInfo->lua = lua;

	delegateClassObject = [MPUniversalDelegateClassObject registerDelegateClassWithInitFunc: luaDelegateInit
																			  withCleanFunc: luaDelegateClean
																		 withSetFeatureFunc: luaDelegateSetFeature
																	  withRemoveFeatureFunc: luaDelegateRemoveFeature
																		 withUserInfoLength: sizeof(luaDelegateStruct)	
																			  withClassInfo: classInfo];
		
	[delegateClassObject setUniversalMethod: luaDelegateCallMethod
					withMethodSignatureFunc: luaDelegateMethodSignatureGetter];

	lua_getfield(lua, LUA_REGISTRYINDEX, "delegateClassesScheduledToUnregisterFrom");
	NSMutableArray *delegateClassesScheduledToUnregisterFrom = *(id *)(lua_touserdata(lua, -1));
	lua_pop(lua, 1);

	[delegateClassesScheduledToUnregisterFrom addObject: delegateClassObject];
	LUA_UNLOCK;

	return delegateClassObject;
}

int luaMPRegisterDelegateClass(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;

	MPUniversalDelegateClassObject *dclass;
	dclass = getClassObjectFromTop(lua);

	[[api getObjectSystem] registerDelegate: (Class)dclass];
	LUA_UNLOCK;
	return 0;
}

int luaMPRegisterDelegateClassForFeature(lua_State *lua)
{
	LUA_LOCK;
	LOAD_API;
	NSString *featureName = [NSString stringWithUTF8String: lua_tostring(lua, -1)];
	lua_pop(lua, 1);

	MPUniversalDelegateClassObject *dclass;
	dclass = getClassObjectFromTop(lua);

	[[api getObjectSystem] registerDelegate: (Class)dclass forFeature: featureName];
	LUA_UNLOCK;
	return 0;
}

