#import <parser.h>
#import <Foundation/Foundation.h>
#import <ctype.h>

#import <MPLuaGlobals.h>

@implementation SignatureParser

-init
{
	src = [NSMutableString new];
	tmp = [NSMutableString new];
	signatureStr = [NSMutableString new];
	funcname = [NSMutableString new];
	[super init];
	return self;
}

-(void) dealloc
{
	[src release];
	[tmp release];
	[signatureStr release];
	[funcname release];
	[super dealloc];
}

-(BOOL) isEoln
{
	if (pos >= [src length]) return YES;
	return NO;
}

#define vacuum(c) ((c=='\t')||(c==' '))

-(void) whitespace 
{
	//int st = pos;
	while ((!([self isEoln]))&&([src characterAtIndex: pos]!=':')&&(isalnum([src characterAtIndex: pos])==0)) ++pos;
	//if (pos!=st) NSLog(@"white space: symbols %i to %i", st, pos);
}

-(BOOL) readName: (NSMutableString*) dest
{
	[self whitespace];
	NSRange r;
	r.location = pos;
	int i=0;
	if (!(isalpha([src characterAtIndex: pos]))) 
	{
		return NO;
	}
	while ((pos+i<[src length]) && isalnum([src characterAtIndex: pos+i]))
	{
		++i;
	}

	r.length = i;
	[dest setString: [src substringWithRange: r]];
	pos += i;
	return YES;
}

- (NSMethodSignature*) parseSignature: (NSString*)theSrc to: (NSMutableString*)theFuncname //"to:" [cr]
{
	// sign ::= [ [type] name [:type {[name]:type}]]

	if([theSrc length] == 0) return nil;
	[src setString:theSrc];

	[funcname setString: @""];
	[signatureStr setString: @""];
	pos = 0;
		
	// *** the parsing starts
	[self whitespace];
	if (![self isEoln])
	{
		if(!isalpha([src characterAtIndex: pos])) return nil;
		if(![self readName: tmp]) return nil;
		[self whitespace];
		if (![self isEoln]) 
		{
		 	if([src characterAtIndex: pos] == ':') //return type is void
			{
				[funcname appendString: tmp];
				[signatureStr appendString: @"v@:"];
			}
			else if (isalpha([src characterAtIndex: pos])) 
			{
				if ([tmp isEqualToString: @"void"])
				{
					[signatureStr appendString: @"v"];
				}
				else
				{
					id ob = [encodingsDictionary objectForKey: tmp];
					if(ob!=nil)
						[signatureStr appendString: ob];
					else return nil;
				}
				[signatureStr appendString: @"@:"];
				[self whitespace];
				if(![self readName: tmp])  return nil;
				[funcname appendString: tmp];
			}
			else return nil;
			
			[self whitespace];
			
			if (![self isEoln])
			{
				if( [src characterAtIndex: pos] == ':') //parse parameters
				{
					pos++;
					[self whitespace];
					if( [self isEoln] ) return nil;
					
					if(![self readName: tmp]) return nil;
					[funcname appendString: @":"];

					id ob = [encodingsDictionary objectForKey: tmp];
					if(ob!=nil)
						[signatureStr appendString: ob];
					else return nil;	

					while(![self isEoln])
					{
						[self whitespace];
						if (isalpha([src characterAtIndex: pos])) //named parameter
						{
							if(![self readName: tmp]) return nil;
							[funcname appendString: tmp];
							[self whitespace];
						}	

						if([src characterAtIndex: pos] !=  ':') return nil;
						
						pos++;
						[funcname appendString: @":"];
						
						[self whitespace];
						
						if(![self readName: tmp]) 
							return nil; // type encoding here

						id ob = [encodingsDictionary objectForKey: tmp];
						if(ob!=nil)
							[signatureStr appendString: ob];
						else return nil;
						[self whitespace];
					}
					
				} 
				else return nil;
			}
		} 
		else 
		{
			[funcname appendString: tmp];
			[signatureStr appendString: @"v@:"];
		}
	}
	else return nil;
	[theFuncname setString: funcname];
	//NSLog(@"%@", funcname);
	//NSLog(@"%@", signatureStr);

	return [NSMethodSignature signatureWithObjCTypes: [signatureStr UTF8String]];
}
@end
