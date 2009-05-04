#import <Foundation/Foundation.h>
#import <MPVariant.p>

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

-(BOOL) isEqual: (id)anObject;
-(NSUInteger) hash;

@end

