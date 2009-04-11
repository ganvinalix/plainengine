#import <Foundation/Foundation.h>
#import <MPUtility.h>
#import <MPLuaGlobals.h>

#import <lua5.1/lua.h>
#import <lua5.1/lauxlib.h>
#import <lua5.1/lualib.h>

#define LOAD_API\
	lua_getfield(lua, LUA_REGISTRYINDEX, "api");\
	id api = *(id *)(lua_touserdata(lua, -1));\
	lua_pop(lua, 1);\

/*
#define LUA_LOCK\
	[luaGlobalLock lock];\
	lua_getfield(lua, LUA_REGISTRYINDEX, "accessMutex");\
	id __lock = *(id *)(lua_touserdata(lua, -1));\
	lua_pop(lua, 1);\
	[luaGlobalLock unlock];\
	[__lock lock];

#define LUA_UNLOCK\
	[__lock unlock];
*/

/*
extern unsigned counter;

#define LUA_LOCK\
	printf("-%d- locking %p at %s:%d\n", ++counter, lua, __FILE__, __LINE__);\
	[luaGlobalLock lock];

#define LUA_UNLOCK\
	[luaGlobalLock unlock];\
	printf("-%d- unlocked %p at %s:%d\n", --counter, lua, __FILE__, __LINE__);
*/


//#define PTR_TO_ID(ptr) [NSString stringWithFormat: @"%p", ptr]
#define PTR_TO_ID(ptr) [NSNumber numberWithUnsignedInt: (NSUInteger)ptr]

#define REGISTER_LUA_STATE(state)\
	[luaGlobalLock lock];\
	[locksDictionary setObject: [[NSRecursiveLock new] autorelease] forKey: PTR_TO_ID(lua)];\
	[luaGlobalLock unlock];

#define UNREGISTER_LUA_STATE(state)\
	[luaGlobalLock lock];\
	[locksDictionary removeObjectForKey: PTR_TO_ID(lua)];\
	[luaGlobalLock unlock];

/*
#define LUA_LOCK\
	[luaGlobalLock lock];\
	id _lock = [locksDictionary objectForKey: PTR_TO_ID(lua)];\
	[luaGlobalLock unlock];\
	[_lock lock];\
	*/

#define LUA_LOCK\
	id _lock = [locksDictionary objectForKey: PTR_TO_ID(lua)];\
	[_lock lock];

#define LUA_UNLOCK\
	[_lock unlock];

void printStack(lua_State *lua);

void pushLuaTableFromStringDictionary(lua_State *lua, id dictionary);

void pushMPObject(lua_State *lua, id object);
id getMPObjectFromStack(lua_State *lua, int index);

id sigConverter(id str);

NSMethodSignature *parseSignature(MPMapper *mapper, NSString *signature, NSMutableString *funcName);

