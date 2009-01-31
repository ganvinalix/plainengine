#ifndef _DICTIONARY_C_
#define _DICTIONARY_C_

#include <stdlib.h>

/** Typedef for pointer to dictionary */
typedef void * dictionary;
/** Typedef for pointer to enumerator */
typedef void * dict_enumerator;

/** Allocates and returns empty ready-to-use dictionary */
dictionary dict_getempty();
/** Allocates new dictionary and fills with content from source; if source is NULL returns NULL;
  * Even if source is closed, copy will be mutable */
dictionary dict_copy(dictionary source);

/** Returns number of entries in dictionary */
long unsigned dict_size(dictionary tree);
/** Returns number that is not less than maximal value length */
long unsigned dict_maxvaluelength(dictionary tree);

/** Searches the tree for object with giver key and returns pointer to value.
  * Returns NULL if didn't found or if tree is NULL;
  */
char const *dict_find(dictionary tree, const char *key);
/** Inserts pair (key, value) into dictionary tree, if such a key exists, replaces. Does nothing if tree is NULL;
  * Returns 1 if entry was added, 0 if entry was replaced, -1 if failed (NULL dictionary or closed dictionary) */
int dict_insert(dictionary tree, const char *key, const char *value);
/** Removes entry with given key. Does nothing if tree is NULL; 
  * Returns 1 if entry was added, 0 if entry was replaced, -1 if failed (NULL dictionary or closed dictionary) */
int dict_remove(dictionary tree, const char *key);

/** Closes dictionary, making it read-only. Any changes will give no result. Does nothing if tree is NULL */
void dict_close(dictionary tree);

/** Empties dictionary. Does nothing if tree is NULL */
void dict_clear(dictionary tree);

/** Frees memory, used by dictionary. Does nothing if tree is NULL */
void dict_free(dictionary tree);

/** Returns key enumerator for dictionary. Order is undefined. Does nothing if tree is NULL */
dict_enumerator dict_get_keyenumerator(dictionary tree);
/** Returns object enumerator for dictionary. Order is undefined. Does nothing if tree is NULL */
dict_enumerator dict_get_valueenumerator(dictionary tree);

/** Returns current enumerator value or NULL if enumeration finished;
  * Enumerator position increased. Does nothing if enumerator is NULL
  */
char const *dict_enumerator_next(dict_enumerator enumerator);

/** Frees memory, used by enumerator. Does nothing if enumerator is NULL */
void dict_free_enumerator(dict_enumerator enumerator);

#endif //_DICTIONARY_C_

