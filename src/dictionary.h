#include <stdlib.h>

typedef struct
{
	char *key, *value;
	struct dictionary_node *left, *right;
} dictionary_node;

typedef struct
{
	int ismutable;
	dictionary_node *root;
	long unsigned size;
} dictionary;

/*typedef void (DICT_ENUM)(char*, void*);	
					  Enumeration function type 
					  First parameter contains current key or value;
					  Second - tag that contains user information;
					 */

typedef struct
{
	char *val;
	struct dict_enumerator_data *next;
} dict_enumerator_data;

typedef struct
{
	dict_enumerator_data *first;
	dict_enumerator_data *current;
} dict_enumerator;

typedef dict_enumerator_data* dict_enumerator_store_type;

dictionary *dict_getempty();
dictionary *dict_copy(dictionary *source);

long unsigned dict_size(dictionary *tree);

int dict_find(dictionary *tree, char *key, char *valuebuf);
void dict_insert(dictionary *tree, char *key, char *value);
void dict_remove(dictionary *tree, char *key);
void dict_close(dictionary *tree);
void dict_clear(dictionary *tree);
void dict_free(dictionary *tree);

// void dict_enumerate_keys(dictionary *tree, void *tag, DICT_ENUM func);
// void dict_enumerate_values(dictionary *tree, void *tag, DICT_ENUM func);

dict_enumerator *dict_get_keyenumerator(dictionary *tree);
dict_enumerator *dict_get_valueenumerator(dictionary *tree);

char *dict_enumerator_next(dict_enumerator *enumerator);

dict_enumerator_store_type dict_store_enumerator(dict_enumerator *enumerator);
void dict_restore_enumerator(dict_enumerator_store_type stamp, dict_enumerator *enumerator);

void dict_free_enumerator(dict_enumerator *enumerator);

