#import <MPLuaHelpers.h>

void pushLuaTableFromStringDictionary(lua_State *lua, id dictionary)
{
	NSUInteger count = [dictionary count];
	lua_createtable(lua, 0, count);
	int msgdata = lua_gettop(lua);
	if (count)
	{
		NSEnumerator *enumer;
		enumer = [dictionary keyEnumerator];
		NSString *key;
		while ((key = [enumer nextObject]) != nil)
		{
			lua_pushstring(lua, [[dictionary objectForKey: key] UTF8String]);
			lua_setfield(lua, msgdata, [key UTF8String]);
		}
	}
}

