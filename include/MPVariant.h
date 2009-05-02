#import <Foundation/Foundation.h>
#import <MPVariant.p>

/** This class is an universal data container that support NSString, NSInteger and double types and conversion between them;*/
@interface MPVariant : NSObject <MPVariant, NSCoding, NSCopying>
{
	MPVariantType type;
	NSMutableString *theStringValue;
	double theDoubleValue;
	NSInteger theIntegerValue;
	BOOL strComputed, doubleComputed, intComputed;
}

/** Initializes this with none data */
-init;
/** Initializes this with given NSString */
-initWithString: (NSString *)newvalue;
/** Initializes this with given NSInteger */
-initWithInteger: (NSInteger)newvalue;
/** Initializes this with given double */
-initWithDouble: (double)newvalue;
/** Initializes this without allocation memory for data; For internal use */
-initWithNothing;

/** Returns new empty MPVariant */
+variant;
/** Returns new MPVariant with given NSString*/
+variantWithString: (NSString *)newvalue;
/** Returns new MPVariant with given NSInteger*/
+variantWithInteger: (NSInteger)newvalue;
/** Returns new MPVariant with given double*/
+variantWithDouble: (double)newvalue;

/** Copies reciever and allocates copy in given zone */
-copyWithZone: (NSZone *)zone;
/** Copies reciever */
-copy;

/** Deallocates reciever */
-(void) dealloc;

/** Returns data type */
-(MPVariantType) dataType;

-(BOOL) isEqual: (id)anObject;
-(NSUInteger) hash;

/** Returns value as NSString */
-(NSString *) stringValue;
/** Returns value as NSInteger */
-(NSInteger) integerValue;
/** Returns value as double */
-(double) doubleValue;

/** Equal to stringValue */
-(NSString *) description;

@end

