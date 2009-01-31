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
	methodList = class_nextMethodList(_class, &iterator);
	if(methodList == NULL) return nil;
	_method = methodList->method_list[i];

	[super init];
	return self;
}
- (void) dealloc
{
	//
	[super dealloc];
}
//
- (SEL) getMethodName
{
	return _method.method_name;
}
/*- (char *) getMethodTypes
{
	return _method.method_types;
}*/
- (IMP) getMethodImplementation
{
	return _method.method_imp;
}
//
- (BOOL) moveToNext
{
	if(i >= methodList->method_count-1)
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
@end

//
id<MPMethodList> MPGetMethodListForClass(Class cls)
{
	return [[[MPMethodList alloc] initWithClass: cls] autorelease];
}

