#ifndef _DICTIONARY_C_
#define _DICTIONARY_C_

#include <stdlib.h>

typedef struct tagDN 
{
	char *key, *value;
	struct tagDN *left, *right;
} dictionary_node;

typedef struct tagD
{
	int ismutable;
	dictionary_node *root;
	long unsigned size;
} dictionary;

typedef struct tagDED
{
	char *val;
	struct tagDED *next;
} dict_enumerator_data;

typedef struct tagDE
{
	dict_enumerator_data *first;
	dict_enumerator_data *current;
} dict_enumerator;

//typedef dict_enumerator_data* dict_enumerator_store_type;

dictionary *dict_getempty();
dictionary *dict_copy(dictionary *source);

long unsigned dict_size(dictionary *tree);

int dict_find(dictionary *tree, const char *key, char *valuebuf);
void dict_insert(dictionary *tree, const char *key, const char *value);
void dict_remove(dictionary *tree, const char *key);
void dict_close(dictionary *tree);
void dict_clear(dictionary *tree);
void dict_free(dictionary *tree);

dict_enumerator *dict_get_keyenumerator(dictionary *tree);
dict_enumerator *dict_get_valueenumerator(dictionary *tree);

char *dict_enumerator_next(dict_enumerator *enumerator);

/*
dict_enumerator_store_type dict_store_enumerator(dict_enumerator *enumerator);
void dict_restore_enumerator(dict_enumerator_store_type stamp, dict_enumerator *enumerator);
*/

void dict_free_enumerator(dict_enumerator *enumerator);

#endif

