#import <ClassInspection.h>
#import <common.h>

@interface MPMethodList : NSObject <MPMethodList>
{
	void *iterator;
	Method _method;
	struct objc_method_list *methodList;
	NSUInteger i;
	Class _class;
}
- initWithClass: (Class)cls;
@end

@implementation MPMethodList
- initWithClass: (Class)cls
{
	iterator = NULL;
	i = 0;
	_class = cls;

	// check that list isn't empty
	methodList = class_nextMethodList(_class, &iterator);
	if(methodList == NULL) return nil;
	// assign default value
	_method = methodList->method_list[i];
	// rewind
	[self rewind];

	[super init];
	return self;
}
- (void) dealloc
{
	//
	[super dealloc];
}
//
- (SEL) methodName
{
	return _method.method_name;
}
/*- (char *) getMethodTypes
{
	return _method.method_types;
}*/
- (IMP) methodImplementation
{
	return _method.method_imp;
}
//
- (BOOL) nextMethod
{
	if(!(methodList && iterator))
		methodList = class_nextMethodList(_class, &iterator);
	else if(i >= methodList->method_count-1)
	{
		methodList = class_nextMethodList(_class, &iterator);
		if(methodList == NULL)
		{
			return NO;
		}
		i = 0;
	}
	else
	{
		++i;
	}
	_method = methodList->method_list[i];
	return YES;
}
- (void) rewind
{
	methodList = NULL;
	iterator = NULL;
}

@end

//
id<MPMethodList> MPGetMethodListForClass(Class cls)
{
	return [[[MPMethodList alloc] initWithClass: cls] autorelease];
}

