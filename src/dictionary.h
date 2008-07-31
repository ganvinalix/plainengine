#ifndef _DICTIONARY_C_
#define _DICTIONARY_C_

#include <stdlib.h>

/** Internal structure. Don't use! */
typedef struct tagDN 
{
	char *key, *value;
	struct tagDN *left, *right;
} dictionary_node;

/** Dictionary structure. Use only as pointer. WARNING: Never work directly with structure contents! */
typedef struct tagD
{
	int ismutable;
	dictionary_node *root;
	long unsigned size;
} dictionary;

/** Internal structure. Don't use! */
typedef struct tagDED
{
	char *val;
	struct tagDED *next;
} dict_enumerator_data;

/** Dictionary enumerator structure. Use only as pointer. WARNING: Never work directly with structure contents! */
typedef struct tagDE
{
	dict_enumerator_data *first;
	dict_enumerator_data *current;
} dict_enumerator;

//typedef dict_enumerator_data* dict_enumerator_store_type;

/** Allocates and returns empty ready-to-use dictionary */
dictionary *dict_getempty();
/** Allocates new dictionary and fills with content from source */
dictionary *dict_copy(dictionary *source);

/** Returns number of entries in dictionary */
long unsigned dict_size(dictionary *tree);

/** Searches tree for object with given key and writes result in valuebuf.
  * valuebuf must contain legal address or be NULL (then result isn't stored)
  * Returns 1 if succeed, 0 if failed. Returns 0 if tree is NULL;
  */
int dict_find(dictionary *tree, const char *key, char *valuebuf);
/** Inserts pair (key, value) into dcitionary tree, if such a key exists, replaces. Does nothing if tree is NULL*/
void dict_insert(dictionary *tree, const char *key, const char *value);
/** Removes entry with given key. Does nothing if tree is NULL */
void dict_remove(dictionary *tree, const char *key);
/** Closes dictionary, making it read-only. Any changes will give no result. Does nothing if tree is NULL */
void dict_close(dictionary *tree);
/** Empties dictionary. Does nothing if tree is NULL */
void dict_clear(dictionary *tree);
/** Frees memory, used by dictionary. Does nothing if tree is NULL */
void dict_free(dictionary *tree);

/** Returns key enumerator for dictionary. Order is undefined. Does nothing if tree is NULL */
dict_enumerator *dict_get_keyenumerator(dictionary *tree);
/** Returns object enumerator for dictionary. Order is undefined. Does nothing if tree is NULL */
dict_enumerator *dict_get_valueenumerator(dictionary *tree);

/** Returns current enumerator value or NULL if enumeration finished;
  * Enumerator position increased. Does nothing if enumerator is NULL
  */
char *dict_enumerator_next(dict_enumerator *enumerator);

/** Frees memory, used by enumerator. Does nothing if enumerator is NULL */
void dict_free_enumerator(dict_enumerator *enumerator);

#endif //_DICTIONARY_C_

