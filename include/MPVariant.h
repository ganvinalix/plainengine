#import <Foundation/Foundation.h>
#import <MPVariant.p>

typedef enum
{
	type_none=0,
	type_string,
	type_int,
	type_binary,
	type_double
} MPVariantType;

/** This class is an universal data container that support NSString, NSInteger and double types and conversion between them;*/
@interface MPVariant : NSObject <MPVariant, NSCoding, NSCopying>
{
	MPVariantType type;
	NSMutableString *theStringValue;
	NSMutableData *theBinaryDataValue;
	double theDoubleValue;
	NSInteger theIntegerValue;
	BOOL strComputed, doubleComputed, intComputed, binComputed;
}

/** Initializes this without allocation memory for data; For internal use */
-initWithNothing;
/** Initializes this with none data */
-init;
/** Initializes this with given NSString */
-initWithString: (NSString *)newvalue;
/** Initializes this with given NSInteger */
-initWithInteger: (NSInteger)newvalue;
/** Initializes this with given double */
-initWithDouble: (double)newvalue;
/** Initializes this with given NSData */
-initWithBinaryData: (NSData *)newvalue;

/** Returns new empty MPVariant */
+variant;
/** Returns new MPVariant with given NSString*/
+variantWithString: (NSString *)newvalue;
/** Returns new MPVariant with given NSInteger*/
+variantWithInteger: (NSInteger)newvalue;
/** Returns new MPVariant with given double*/
+variantWithDouble: (double)newvalue;
/** Returns new MPVariant with given NSData */
+variantWithBinaryData: (NSData *)newvalue;

-(BOOL) isEqual: (id)anObject;
-(NSUInteger) hash;

-(void) dealloc;

@end

