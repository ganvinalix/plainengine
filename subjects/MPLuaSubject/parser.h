#import <Foundation/Foundation.h>

@interface SignatureParser: NSObject
{
	NSMutableString *funcname, *signatureStr, *tmp,*src;
	unsigned int pos;
}

#define isLetter(c) (((c>='a')&&(c<='z'))||((c>='A')&&(c<='Z')))
#define isDigit(c) (c>='1')&&(c<='9')

-init;
-(void) dealloc;

-(void) whitespace;
-(BOOL) readName: (NSMutableString*) dest;
-(BOOL) isEoln;
-(NSMethodSignature*) parseSignature: (NSString*) theSrc to: (NSMutableString*) theFuncname;

@end

