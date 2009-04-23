#import <lua5.1/lua.h>
#import <lua5.1/lauxlib.h>
#import <lua5.1/lualib.h>

int lua_ALERT(lua_State *lua);
int luaErrorHandler(lua_State *lua);

int luaMPLog(lua_State *lua); 

int luaMPPostMessage(lua_State *lua);
int luaMPPostRequest(lua_State *lua);

int luaMPYield(lua_State *lua);

int luaMPGetMilliseconds(lua_State *lua);

int luaMPObjectByName(lua_State *lua);
int luaMPObjectByHandle(lua_State *lua);
int luaMPNewObject(lua_State *lua);
int luaMPCreateObject(lua_State *lua);
int luaMPGetAllObjects(lua_State *lua);
int luaMPGetObjectsByFeature(lua_State *lua);

int luaMPRegisterDelegateClass(lua_State *lua);
int luaMPRegisterDelegateClassForFeature(lua_State *lua);

int luaMPObjectSystemMetaTable_index(lua_State *lua);

int luaMPObjectMetaTable_index(lua_State *lua);
int luaMPObjectMetaTable_newindex(lua_State *lua);
int luaMPObjectMetaTable_eq(lua_State *lua);
int luaMPObjectMetaTable_gc(lua_State *lua);


