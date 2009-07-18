#import <Foundation/Foundation.h>
#import <MPUtility.h>
#import <MPLuaGlobals.h>

#import <lua5.1/lua.h>
#import <lua5.1/lauxlib.h>
#import <lua5.1/lualib.h>

#define LOAD_API\
	id api;\
	{\
		lua_getfield(lua, LUA_REGISTRYINDEX, "api");\
		api = *(id *)(lua_touserdata(lua, -1));\
		lua_pop(lua, 1);\
	}


//#define PTR_TO_ID(ptr) [NSString stringWithFormat: @"%p", ptr]
#define PTR_TO_ID(ptr) [NSNumber numberWithUnsignedInt: (NSUInteger)ptr]

#define REGISTER_LUA_STATE(state)\
	{\
		[luaGlobalLock lock];\
		MPSpinLock *_lock = [[MPSpinLock alloc] initWithLockClass: [NSRecursiveLock class]];\
		[locksDictionary setObject: _lock forKey: PTR_TO_ID(lua)];\
		[_lock release];\
		[luaGlobalLock unlock];\
	}

#define UNREGISTER_LUA_STATE(state)\
	{\
		[luaGlobalLock lock];\
		[locksDictionary removeObjectForKey: PTR_TO_ID(lua)];\
		[luaGlobalLock unlock];\
	}

#define LUA_LOCK\
	id _lock = [locksDictionary objectForKey: PTR_TO_ID(lua)];\
	[_lock lock];\

#define LUA_UNLOCK\
	[_lock unlock]

#define LUA_UNLOCK_AND_RETURN(retval)\
	{\
		[_lock unlock];\
		return retval;\
	}

#define LUA_UNLOCK_AND_RETURN_VOID\
	{\
		[_lock unlock];\
		return;\
	}

void printStack(lua_State *lua);

void pushLuaTableFromStringDictionary(lua_State *lua, id dictionary);

void pushMPObject(lua_State *lua, id object, BOOL shouldRetain);
id getMPObjectFromStack(lua_State *lua, int index, BOOL *isRetained);

id sigConverter(id str);

NSMethodSignature *parseSignature(MPMapper *mapper, NSString *signature, NSMutableString *funcName);

