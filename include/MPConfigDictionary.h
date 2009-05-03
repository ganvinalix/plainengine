#import <Foundation/Foundation.h>

/**
	<p>Creates a config dicionary from deafults and user options:</p>
	<p>
	1) Firstly function copies defaults to result dictionary,<br></br>
	2) Then it looks for modifications in user dictionary.<br></br>
	3) And if ones are exist - applies this ones.<br></br>
	</p>
*/
NSDictionary *MPCreateConfigDictionary(NSDictionary *defaultsDict, NSDictionary *userDict);

