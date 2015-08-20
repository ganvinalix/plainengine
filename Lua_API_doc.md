#summary Lua API documentation for MPLuaSubject
#labels Phase-Implementation,Featured

# Lua bindings for plainEngine #
_Provides full plainEngine api to lua_



## Basic ##
Script is searched for _'init', 'start', 'update'_ and _'stop'_ functions.
  * `init()` - function is called on Lua subject starting and should contain subject initialization code
> > (object creation, delegate registration, etc.) and should not contain any another-subject-dependant actions
> > (e.g. delegate calls) because necessary subjects might have been not initialized yet.
  * `start()`- function is called on Lua subject first update and should contain another-subject-dependant actions as this subjects
> > had already been initiaized on 'init' time.
  * `update()` - function runs every update.
  * `stop()` - function is called on exit and should contain deinitialization code and should not contain any another-subject-dependant
> > actions because this subjects might have been deinitialized already.
This functions should not return any value.

## Logging ##
To send message to log, you should use function `MPLog(level, msg)`
First argument is log level (you should use level constants _(info, notice, warning, etc.)_). Second argument is string which would be sent to log. Also you may use `MPLog(msg)`, it is equal to `MPLog(notice, msg)`.

## Yields ##
To use plainEngine yields, you should use function `MPYield()`.

## Posting a message ##
To post a plainEngine notification, you should use function `MPPostMessage(name[, paramsTable])`. First argument is, well, message name. Second (optional) argument is lua table with message params.

## Posting a request ##
To post a plainEngine request, you should use function `MPPostRequest(name[, paramsTable])`. First argument is request name. Second (optional) argument is lua table with request params. Returns string with result (empty string if there is no one)

## Handling messages ##
To handle some message, you should declare function of a table _MPMessageHandlers_ - `MPMessageHandlers.<message_name>(args)`.
First and only argument would be lua table with message params.	If you want to set any message handler, declare a function `MPHandlerOfAnyMessage(name, args)`. Therefore, first argument would be name of message you caught and second - table of params.

## Working with objects ##
Firstly, the object is userinfo object with metatable, which responds to four events: `__index` (which connects method names to functions), `__newindex` (which provides simple interface to features), `__eq` and `__gc`.

While you can call to object in your script, it is retained.

To get _MPObject_ by name, you should use either table `MPObjects` (name per object) or function `MPObjectByName(name)`. To get it by handle, use function `MPObjectByHandle(handle)`. **nil** would be returned if not found.

To create plainEngine object, you should use functions `MPNewObject(name)` and `MPCreateObject(name)`. The difference is that objects, created with `MPNewObject`, **must be** released manually with `object.release` and objects, created by `MPCreateObject` **must NOT be** released manually as they would be released automatically after stop.

Also you may use functions `MPGetAllObjects()` (returns array with all objects) and `MPGetObjectsByFeature(featurename)` (returns array with all objects with given feature)

To get object methods, you should use `object:methodname` (or `object["methodName"](object, ...)` ). The result would be function, analogical to corresponding method. If methodName contains ':' symbols, you can't use object:methodName syntax, but you can use _MPMethodAliasTable_. It is global table, which maps method aliases to their real names. When method is called, it is firstly checked if there is alias for it. If there is, method mapped to this alias in MPMethodAliasTable is called. For example, you want expression `obj["setXYZ:::"](obj, 0, 0, 0)` to become less ugly.
So, in 'start' you declare:
```
function start()
	...
	MPMethodAliasTable["setXYZ"] = "setXYZ:::"
	...
end
```
And then you can call `obj:setXYZ(0, 0, 0)`.

Some methods of MPObject are overloaded in lua MPObject, because they used types, not supported by Lua. They are:

  1. `object:getName()` - returns string with object name;
  1. `object:getHandle()` - returns object handle as number;
  1. `object:hasFeature(fname)` - returns boolean, which is true if objects has feature fname and false otherwise;
  1. `object:copy()` - returns copy of object;
  1. `object:copyWithName(copyname)` - returns copy of object with name _'copyname'_;
  1. `object:getAllFeatures()` - returns table with feature names as keys and their values as values;
  1. `object:getFeatureData(fname)` - returns string with value of feature _'fname'_;
  1. `object:setFeature(fname[, fvalue [,paramsTable]])`	- sets feature _'fname'_ to _'fvalue'_ (default value is empty string) with paramsTable as userInfo;
  1. `object:removeFeature(fname[, paramsTable])` - removes feature 'fname' from object, sending paramsTable as userInfo if there is such;
  1. `object:respondsTo(selName)` - returns true, if object responds to selector 'selName' and false otherwise;

If you want set object feature to some value without sending any params, you may write
```
object.featurename = featurevalue 
```
Instead of
```
object:setFeature(featurename, featurevalue); 
```
But reading features doesn't work in such way, because object.name returns method 'name'

## Declaring delegate classes ##
In Lua, delegate class is a table, which contains a function 'delegateClassTable:newDelegateWithObject(object)' or 'delegateClassTable:new()'. If you want to register delegate class, use functions `MPRegisterDelegateClass(delegateClassTable)` or `MPRegisterDelegateClassForFeature(delegateClassTable, featureName)`.

Delegates instanciate via delegate class functions (`newDelegateWithObject` or `new`). Each delegate must contain table 'signatures' which is array of method signatures (strings) of kind: `"<R> methodname:<t1> :<t2> namedparam:<t3>"`, where `<R>` is return type, `t1` is first argument type etc. (e.g. "double getX" or "void setXYZ:double:double:double").

Types, supported by Lua subject:

| **C Type** | **Lua type name** |
|:-----------|:------------------|
| `double`   | `double`          |
| `float`    | `float`           |
| `long`     | `long`            |
| `unsigned long` | `ulong`           |
| `long long` | `longlong`        |
| `unsigned long long` | `ulonglong`       |
| `char`     | `char`            |
| `unsigned char` | `uchar`           |
| `short`    | `short`           |
| `unsigned short` | `ushort`          |
| `int`      | `int`             |
| `unsigned int` | `uint`            |
| `MPHandle` | `mphandle`        |

Signatures may change freely during delegate lifetime. When the method is called, its selector is searched in signatures array and if found, appropriate function of delegate is called (as `delegate:function`). Special functions are `setFeature(name, value, userInfo)` and `removeFeature(name, userInfo)` which are called (if exist) on feature setting and removing. Also there is `dealloc()` function which is called on delegate remove.

Method must be implemented by function with name, equal to method name, including named params (e.g., method "someMethod:d foo:d:d" must be implemented by function "someMethodfoo").

Example of delegate class:
```

delegateClass =
{
	--generic to all instances
	signatures =
	{
		"double getV";
		"void setV:double";
	}
}
function delegateClass:new()
	return setmetatable(
	{
		--specific to every instance
		v=0
	}, {__index = delegateClass} )
end

function delegateClass:getV()
	return self.v
end

function delegateClass:setV(newv)
	self.v = newv
end

function delegateClass:setFeature(name, value, par)
	MPLog(name)
	MPLog(value)
	for k,v in pairs(par) do
		MPLog(k.." "..v)
	end
end

function delegateClass:removeFeature(name)
	MPLog(name)
end
```