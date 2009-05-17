#import <Foundation/Foundation.h>

/** This class is an universal data container that support NSString, NSInteger, NSData and double types and conversion between them;*/
@protocol MPVariant <NSObject, NSCoding, NSCopying>

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

