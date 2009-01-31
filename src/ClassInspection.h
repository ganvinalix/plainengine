#import <Foundation/Foundation.h>
		
@protocol MPMethodList
- (SEL) getMethodName;
//- (char *) getMethodTypes;
- (IMP) getMethodImplementation;

- (BOOL) moveToNext;
@end

id<MPMethodList> MPGetMethodListForClass(Class cls);

