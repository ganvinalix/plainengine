#import<Foundation/Foundation.h>

/**
	Creates a config dicionary from deafults and user options:
	1) Firstly function copys defalts to resulting dictionary,
	2) then it looks for modifictions in user's dictionary
	3) and if ones exist - applys this ones.
*/
NSDictionary *MPCreateConfigDictionary(NSDictionary *defaultsDict, NSDictionary *userDict);

