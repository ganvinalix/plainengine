#import <MPCore.h>
#import <lua5.1/lua.h>
#import <lua5.1/lauxlib.h>
#import <lua5.1/lualib.h>

/**
	Lua bindings for plainEngine.
	Provides full plainEngine api to lua.

	1) Basic
 	 	Script is searched for 'init', 'update' and 'stop' functions.
		If succeed, this functions are called on corresponding events.
		This functions must not have any arguments/
	2) Logging
		To send message to log, you should use function MPLog(level, msg)
		First argument is log level (you should use level constants (info, notice, warning, etc.) ).
		Second argument is string which would be sent to log.
	3) Posting a message.
		To post a plainEngine notification, you should use function MPPostMessage(name[, paramsTable])
		First argument is, well, message name.
		Second (optional) argument is lua table with message params.
	4) Handling messages.
		To handle some message, you should declare function MPHandlerOfMessage_<message name> (args).
		First and only argument would be lua table with message params.
		If you want to set any message handler, declare a function MPHandlerOfAnyMessage(name, args).
		Therefore, first argument would be name of message you caught and second - table of params.
	5) Working with objects.
		Firstly, the object is userinfo object with metatable, which responds to three events:
		__index (which connects method names to functions), __newindex (which provides simple interface to features) and __eq.

		To get MPObject, you should use either table MPObjects (name per object) or function MPObjectByName(name).
		Nil would be returned if not found.

		To create plainEngine object, you should use functions MPNewObject(name) and MPCreateObject(name).
		The difference is that objects, created with MPNewObject, must be released manually with object.release and
		objects, created by MPCreateObject must NOT be released manually as they would be released automatically after stop.

		Also you may use functions MPGetAllObjects() (returns array with all objects) and MPGetObjectsByFeature(featurename)
		(returns array with all objects with given feature)

		To get object methods, as it was told before, you should use object.methodname (or object["methodName"]).
		The result would be function, analogical to corresponding method.
		If methodName contains ':' symbols, you can't use object.methodName syntax, but you can use MPMethodAliasTable.
		It is global table, which maps method aliases to their real names. When method is called, it is firstly checked
		if there is alias for it. If there is, method mapped to this alias in MPMethodAliasTable is called.
		
		For	example, you want expression 'obj["setXYZ:::"](0, 0, 0)' to become less ugly.
		So, in 'start' you declare:

			function start()
				...
				MPMethodAliasTable["setXYZ"] = "setXYZ:::"
				...
			end

		And then you can call 'obj.setXYZ(0, 0, 0)'.

		Some methods of MPObject are overloaded in lua MPObject, because they used types, not supported by Lua.
		They are:
		
		object.getName()				- returns string with object name;
		object.getHandle()				- returns object handle as number;
		object.hasFeature(fname)		- returns boolean, which is true if objects has feature fname and false otherwise
		object.copy()					- returns copy of object;
		object.copyWithName(copyname)	- returns copy of object with name 'copyname'
		object.getAllFeatures()			- returns table with feature names as keys and their values as values.
		object.getFeatureData(fname)	- returns string with value of feature 'fname'.

		object.setFeature(fname[, fvalue [,paramsTable]])	- sets feature 'fname' to 'fvalue'
											(default value is empty string) with paramsTable as userInfo.
		object.removeFeature(fname[, paramsTable])			- removes feature 'fname' from object, sending paramsTable as userInfo if there is such.

		If you want set object feature to some value without sending any params, you may write
			object.featurename = featurevalue
		Instead of
			object.setFeature(featurename, featurevalue);

		But reading features doesn't work in such way, because object.name returns method 'name'


  */
@interface MPLuaSubject : NSObject <MPSubject>
{
	id <MPAPI> api;
	lua_State *lua;
	NSString *scriptFileName;
	NSMutableArray *objectsScheduledToRelease;

	BOOL hasUpdateMethod;
}

MP_HANDLER_OF_ANY_MESSAGE;
@end



