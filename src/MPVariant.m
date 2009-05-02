#import <MPVariant.h>

@implementation MPVariant

-init
{
	[self initWithNothing];
	theStringValue = [[NSMutableString alloc] init];
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

-initWithNothing
{
	[super init];
	strComputed = intComputed = doubleComputed = NO;
	type = type_none;
	theStringValue = nil;
	theDoubleValue = 0.f;
	theIntegerValue = 0;
	return self;
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
		return [[self stringValue] isEqual: [obj stringValue]];
	}
	else if ([anObject isKindOfClass: [NSNumber class]])
	{
		return [[self stringValue] isEqual: [anObject stringValue]];
	}
	else if ([anObject isKindOfClass: [NSString class]])
	{
		return [[self stringValue] isEqual: anObject];
	}
	return NO;
}

-(NSUInteger) hash
{
	return [[self stringValue] hash];
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

-(void) encodeWithCoder: (NSCoder *)encoder
{
	[encoder encodeObject: [self stringValue]	forKey: @"MPVariant_value"];
	[encoder encodeInt: type					forKey: @"MPVariant_type"];
}

-(id) initWithCoder: (NSCoder *)decoder
{
	strComputed = YES;
	intComputed = NO;
	doubleComputed = NO;
	theStringValue = [[decoder decodeObjectForKey: @"MPVariant_value"] retain];
	type = [decoder decodeIntForKey: @"MPVariant_type"];
	switch (type)
	{
		case type_none:
			break; //nop
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
	return self;
}

-(void) dealloc
{
	[theStringValue release];
	[super dealloc];
}

-(MPVariantType) dataType
{
	return type;
}

-(NSString *) stringValue
{
	if (!strComputed)
	{
		switch (type)
		{
		case type_none:
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
	return [[theStringValue copy] autorelease];
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

-(NSString *) description
{
	return [self stringValue];
}

@end

