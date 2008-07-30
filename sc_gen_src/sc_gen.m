#import <Foundation/Foundation.h>

int main(int argc, char **argv)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSString *inputFileName = nil, *outputFileName = nil;

	if (argc>1)
	{
		inputFileName = [NSString stringWithUTF8String: argv[1]];
	}
	else
	{
		inputFileName = @"error_names.txt";
	}
	if (argc>2)
	{
		outputFileName = [NSString stringWithUTF8String: argv[2]];
	}
	else
	{
		outputFileName = [inputFileName stringByDeletingPathExtension];
	}
	

	NSString *inputFileContents = [NSString stringWithContentsOfFile: inputFileName 
			// encoding: NSASCIIStringEncoding 
			// error: nil
			];
	NSArray *constantsNames = [inputFileContents componentsSeparatedByString: @"\n"];

	NSMutableString *outm = nil, *outh = nil;
	outh = [NSMutableString stringWithString: @"#import <Foundation/Foundation.h>\n\n"];
	outm = [NSMutableString stringWithFormat:@"#import <%@.h>\n\n", outputFileName];

	NSEnumerator *enumer = [constantsNames objectEnumerator];
	NSString *currentName = nil;
	while ((currentName = [enumer nextObject]) != nil)
	{
		currentName = [currentName stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([currentName length] == 0)
		{
			continue;
		}
		[outh appendFormat: @"extern NSString *const %@;\n", currentName];
		[outm appendFormat: @"NSString *const %@ = @\"%@\";\n", currentName, currentName];
	}

	[outh appendString: @"\n"];
	[outm appendString: @"\n"];

	[outh writeToFile: [NSString stringWithFormat: @"%@.h", outputFileName] atomically: YES /*encoding: NSASCIIStringEncoding error: nil*/];
	[outm writeToFile: [NSString stringWithFormat: @"%@.m", outputFileName] atomically: YES /*encoding: NSASCIIStringEncoding error: nil*/];

	[pool release];
	return 0;
}

