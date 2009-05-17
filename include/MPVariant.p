#import <Foundation/Foundation.h>

typedef enum
{
	type_none=0,
	type_string,
	type_int,
	type_binary,
	type_double
} MPVariantType;


/** This class is an universal data container that support NSString, NSInteger and double types and conversion between them;*/
@protocol MPVariant <NSObject, NSCoding, NSCopying>

//** Returns data type */
-(MPVariantType) dataType;

/** Returns value as NSString */
-(NSString *) stringValue;
/** Returns value as NSInteger */
-(NSInteger) integerValue;
/** Returns value as double */
-(double) doubleValue;
/** Returns value as NSData */
-(NSData *) binaryDataValue;

/** Copies reciever */
-(id) copy;

/** Equal to stringValue */
-(NSString *) description;

@end

