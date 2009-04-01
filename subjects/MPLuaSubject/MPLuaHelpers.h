#import <Foundation/Foundation.h>

#import <lua5.1/lua.h>
#import <lua5.1/lauxlib.h>
#import <lua5.1/lualib.h>

void pushLuaTableFromStringDictionary(lua_State *lua, id dictionary);

