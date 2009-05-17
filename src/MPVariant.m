#import <MPVariant.h>

@implementation MPVariant

-init
{
	[self initWithNothing];
	theStringValue = [NSMutableString new];
	theBinaryDataValue = [NSMutableData new];
	return self;
}

-initWithString: (NSString *)newvalue
{
	[self init];
	type = type_string;
	strComputed = YES;
	[theStringValue setString: newvalue];
	return self;
}

-initWithInteger: (NSInteger)newvalue
{
	[self init];
	type = type_int;
	intComputed = YES;
	theIntegerValue = newvalue;
	return self;
}

-initWithDouble: (double)newvalue
{
	[self init];
	type = type_double;
	doubleComputed = YES;
	theDoubleValue = newvalue;
	return self;

}

-initWithBinaryData: (NSData *)newvalue
{
	[self init];
	type = type_binary;
	binComputed = YES;
	[theBinaryDataValue setData: newvalue];
	return self;
}

-initWithNothing
{
	[super init];
	strComputed = intComputed = doubleComputed = binComputed = NO;
	type = type_none;
	theStringValue = nil;
	theBinaryDataValue = nil;
	theDoubleValue = 0.f;
	theIntegerValue = 0;
	return self;
}

+variant
{
	return [[MPVariant alloc] init];
}

+variantWithString: (NSString *)newvalue
{
	return [[[MPVariant alloc] initWithString: newvalue] autorelease];
}

+variantWithInteger: (NSInteger)newvalue
{
	return [[[MPVariant alloc] initWithInteger: newvalue] autorelease];
}

+variantWithDouble: (double)newvalue
{
	return [[[MPVariant alloc] initWithDouble: newvalue] autorelease];
}

+variantWithBinaryData: (NSData *)newvalue
{
	return [[[MPVariant alloc] initWithBinaryData: newvalue] autorelease];
}

-(MPVariantType) dataType
{
	return type;
}

-(void) encodeWithCoder: (NSCoder *)encoder
{
	if (type != type_binary)
	{
		[encoder encodeObject: [self stringValue]	forKey: @"MPVariant_value"];
	}
	else
	{
		[encoder encodeObject: [self binaryDataValue]	forKey: @"MPVariant_value"];
	}
	[encoder encodeInt: type	forKey: @"MPVariant_type"];
}

-(id) initWithCoder: (NSCoder *)decoder
{
	intComputed = NO;
	doubleComputed = NO;
	binComputed = NO;
	strComputed = NO;
	type = [decoder decodeIntForKey: @"MPVariant_type"];
	if (type != type_binary)
	{
		strComputed = YES;
		theStringValue = [[decoder decodeObjectForKey: @"MPVariant_value"] retain];
		theBinaryDataValue = [NSMutableData new];
		switch (type)
		{
			case type_none:
				break; //nop
			case type_binary:
				break; //would not happen
			case type_string:
				break; //nop (already loaded before)
			case type_double:
				doubleComputed = YES;
				theDoubleValue = [theStringValue doubleValue];
				break;
			case type_int:
				intComputed = YES;
				theIntegerValue = [theStringValue integerValue];
				break;
		}
	}
	else
	{
		binComputed = YES;
		theStringValue = [NSMutableString new];
		theBinaryDataValue = [[decoder decodeObjectForKey: @"MPVariant_value"] retain];
	}
	return self;
}

-(void) dealloc
{
	[theBinaryDataValue release];
	[theStringValue release];
	[super dealloc];
}

-(NSString *) stringValue
{
	NSMutableData *convData = nil;
	if (!strComputed)
	{
		switch (type)
		{
		case type_none:
			break;
		case type_binary:
			convData = [NSMutableData dataWithData: theBinaryDataValue];
			[convData appendBytes: "\0" length: sizeof("\0")]; //Now string is correct (null-terminated) in any case
			[theStringValue setString: [NSString stringWithUTF8String: [convData bytes]]];
			break;
		case type_string:
			//This should not happen;
			NSAssert(0, @"MPVariant error: type is 'string' but value of this type undefined");
			break;
		case type_double:
			[theStringValue setString: [NSString stringWithFormat: @"%lf", theDoubleValue]];
			break;
		case type_int:
			[theStringValue setString: [NSString stringWithFormat: @"%ld", theIntegerValue]];
			break;
		}
		strComputed = YES;
	}
	return theStringValue;
}

-(NSInteger) integerValue
{
	if (!intComputed)
	{
		switch (type)
		{
			case type_none:
				break;
			case type_int:
				//This should not happen;
				NSAssert(0, @"MPVariant error: type is 'int' but value of this type undefined");
				break;
			case type_binary:
				theIntegerValue = [[self stringValue] integerValue];
				break;
			case type_string:
				theIntegerValue = [theStringValue integerValue];
				break;
			case type_double:
				theIntegerValue = theDoubleValue;
				break;
		}
		intComputed = YES;
	}
	return theIntegerValue;
}

-(double) doubleValue
{
	if (!doubleComputed)
	{
		switch (type)
		{
			case type_none:
				break;
			case type_double:
				//This should not happen;
				NSAssert(0, @"MPVariant error: type is 'double' but value of this type undefined");
				break;
			case type_binary:
				theDoubleValue = [[self stringValue] doubleValue];
				break;
			case type_string:
				theDoubleValue = [theStringValue doubleValue];
				break;
			case type_int:
				theDoubleValue = theIntegerValue;
				break;
		}
		doubleComputed = YES;
	}

	return theDoubleValue;
}

-(NSData *) binaryDataValue
{
	if (!binComputed)
	{
		NSAssert(type != type_binary, @"MPVariant error: type is 'binary' but value of this type undefined");
		NSString *strValue = [self stringValue];
		[theBinaryDataValue setData: [strValue dataUsingEncoding: NSUTF8StringEncoding]];
		[theBinaryDataValue appendBytes: "\0" length: sizeof("")]; //terminator
		binComputed = YES;
	}

	return theBinaryDataValue;
}

-copyWithZone: (NSZone *)zone
{
	return [self retain];
}

-copy
{
	return [self copyWithZone: NULL];
}

-(BOOL) isEqual: (id)anObject
{
	if ([anObject isKindOfClass: [MPVariant class]])
	{
		MPVariant *obj = anObject;
		if (([obj dataType] != type_binary) && (type != type_binary)) //To avoid unnecessary conversion to NSData
		{
			return [[self stringValue] isEqual: [obj stringValue]];
		}
		else
		{
			return [[self binaryDataValue] isEqual: [obj binaryDataValue]];
		}
	}
	else if ([anObject isKindOfClass: [NSNumber class]])
	{
		return [[self stringValue] isEqual: [anObject stringValue]];
	}
	else if ([anObject isKindOfClass: [NSString class]])
	{
		return [[self stringValue] isEqual: anObject];
	}
	else if ([anObject isKindOfClass: [NSData class]])
	{
		return [[self binaryDataValue] isEqual: anObject];
	}
	return NO;
}

-(NSUInteger) hash
{
	return [[self stringValue] hash];
}



-(NSString *) description
{
	return [self stringValue];
}

@end

