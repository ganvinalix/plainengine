#import <Foundation/Foundation.h>
#import <numeric_types.h>

typedef enum
{
	type_none=0,
	type_string,
	type_int,
	//type_uint,
	type_double
} MPVariantType;


/** This class is an universal data container that support NSString, NSInteger and double types and conversion between them;*/
@protocol MPVariant <NSObject, NSCoding, NSCopying>

/** Initializes this with none data */
-init;
/** Initializes this with given NSString */
-initWithString: (NSString *)newvalue;
/** Initializes this with given NSInteger */
-initWithInteger: (NSInteger)newvalue;
/** Initializes this with given double */
-initWithDouble: (double)newvalue;

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

/** Returns value as NSString */
-(NSString *) stringValue;
/** Returns value as NSInteger */
-(NSInteger) integerValue;
/** Returns value as double */
-(double) doubleValue;

/** Equal to stringValue */
-(NSString *) description;

@end

