#import <Foundation/Foundation.h>
		
@protocol MPMethodList
- (SEL) methodName;
//- (char *) getMethodTypes;
- (IMP) methodImplementation;

- (BOOL) nextMethod;
- (void) rewind;
@end

id<MPMethodList> MPGetMethodListForClass(Class cls);

