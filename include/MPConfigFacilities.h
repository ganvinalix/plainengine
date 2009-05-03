#import <Foundation/Foundation.h>
#import <MPConfigDictionary.h>

/** Builds plist from NSData passed as argument */
id MPBuildPlistFromData(NSData *plistData);

/** Builds NSDictionary with options for default log file */
NSDictionary *MPBuildLogOptionsFromPlist(NSDictionary *plist);

/**
 * Search for "$param=default$" (without quotes) in a _str_, 
 * every expression which had been found will be replaced by value of [userOpts objectForKey: param] if it isn't nil
 * and _default_ overwise.
 * If you want to put $ sign into string just put $$.
 * */
NSString *MPPreprocessString(NSString *str, NSDictionary *userOpts);

/** 
 * For each arg which matches pattern "param=value" (without quotes) adds a key-value pair to result dictionary 
 * All arguments as a single string maped for a "argall" key.
 * Argument at index i maped for a "agri" key (where i changes from 1 to (argc-1)).
 * E.g.:	if cmd-line is ./program log=NO foo bar=banana
 *			Result dictionary will be looking like that:
			{
				arg1 = "log=NO";
				log = "NO";
				arg2 = "foo";
				arg3 = "bar=banana";
				bar = "banana";
				argall = "log=NO foo bar=banana";
			}
 * */
NSDictionary *MPBuildDictionaryFromCmd(int agrc, const char *argv[]);

