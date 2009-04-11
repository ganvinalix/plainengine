#import <MPLuaHelpers.h>
#import <parser.h>

void pushLuaTableFromStringDictionary(lua_State *lua, id dictionary)
{
	LUA_LOCK;
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
	LUA_UNLOCK;
}

void pushMPObject(lua_State *lua, id object)
{
	LUA_LOCK;
	if (!object)
	{
		lua_pushnil(lua);
	}
	else
	{
		[object retain];
		id *luaobj = lua_newuserdata(lua, sizeof(id));
		*luaobj = object;
		int objIndex = lua_gettop(lua);
		lua_getfield(lua, LUA_REGISTRYINDEX, "MPObjectMetaTable");	
		lua_setmetatable(lua, objIndex);
	}
	LUA_UNLOCK;
}

id getMPObjectFromStack(lua_State *lua, int index)
{
	LUA_LOCK;
	id obj = *(id *)lua_touserdata(lua, index);
	LUA_UNLOCK;
	return obj;
}

/*

MPObject as tables:

void pushMPObject(lua_State *lua, id object)
{
	if (!object)
	{
		lua_pushnil(lua);
	}
	else
	{
		[object retain];

		lua_createtable(lua, 0, 1);
		int tabIndex = lua_gettop(lua);

		id *luaobj = lua_newuserdata(lua, sizeof(id));
		*luaobj = object;
		
		lua_setfield(lua, tabIndex, "ptr");
		lua_getfield(lua, LUA_REGISTRYINDEX, "MPObjectMetaTable");	
		lua_setmetatable(lua, tabIndex);
	}
}

id getMPObjectFromStack(lua_State *lua, int index)
{
	lua_getfield(lua, index, "ptr");
	id obj = *(id *)lua_touserdata(lua, -1);
	lua_pop(lua, 1);
	return obj;
}


*/

void printStack(lua_State *lua)
{
	LUA_LOCK;
	int i;
	printf("stack:\n");
	for (i=lua_gettop(lua); i >= 1; --i)
	{
		int type = lua_type(lua, i);
		printf("%d: %s - %s\n", i, lua_typename(lua, type), lua_tostring(lua, i));
	}
	printf("\n");
	LUA_UNLOCK;
}

@interface MPLuaSubjectSignatureAndNameWrapper: NSObject
{
	NSMethodSignature *sig;
	NSString *name;
}
-initWithSignature: (NSMethodSignature *)aSig withName: (NSString *)aName;
-(NSMethodSignature *) methodSignature;
-(NSString *) methodName;
-(void) dealloc;
@end

@implementation MPLuaSubjectSignatureAndNameWrapper

-initWithSignature: (NSMethodSignature *)aSig withName: (NSString *)aName
{
	[super init];
	sig = [aSig retain];
	name = [aName copy];
	return self;
}

-(NSMethodSignature *) methodSignature
{
	return sig;
}

-(NSString *) methodName
{
	return name;
}

-(void) dealloc
{
	[sig release];
	[name release];
	[super dealloc];
}

@end

id sigConverter(id str)
{
	NSCAssert1([str isKindOfClass: [NSString class]], @"%@ recieved instead of NSString", NSStringFromClass([str class]));

	SignatureParser *parser = [SignatureParser new];
	NSMutableString *name = [NSMutableString string];
	NSMethodSignature *sig = nil;
	sig = [parser parseSignature: str to: name];
	[parser release];

	return [[[MPLuaSubjectSignatureAndNameWrapper alloc] initWithSignature: sig withName: name] autorelease];
}

NSMethodSignature *parseSignature(MPMapper *mapper, NSString *signature, NSMutableString *funcName)
{
	MPLuaSubjectSignatureAndNameWrapper *data = [mapper getObject: signature];
	[funcName setString: [data methodName]];
	return [data methodSignature];
}

