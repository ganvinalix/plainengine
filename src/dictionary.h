#include <stdlib.h>

typedef struct
{
	char *key, *value;
	struct dictionary_node *left, *right;
} dictionary_node;

typedef struct
{
	dictionary_node *root;
	unsigned size;
} dictionary;

typedef void (DICT_ENUM)(char*, void*); /*	
					  Enumeration function; type 
					  First parameter contains current key or value;
					  Second - tag that contains user information;
					 */

dictionary *dict_getempty();
dictionary *dict_copy(dictionary *source);

unsigned dict_size(dictionary *tree);

int dict_find(dictionary *tree, char *key, char *valuebuf);
void dict_insert(dictionary *tree, char *key, char *value);
void dict_remove(dictionary *tree, char *key);
void dict_clear(dictionary *tree);
void dict_enumerate_keys(dictionary *tree, void *tag, DICT_ENUM func);
void dict_enumerate_values(dictionary *tree, void *tag, DICT_ENUM func);

