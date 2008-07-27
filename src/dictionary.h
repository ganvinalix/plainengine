#include <stdlib.h>

typedef struct
{
	char *key, *value;
	struct dictionary_node *left, *right;
} dictionary_node;

dictionary_node *dict_getempty();

int dict_find(dictionary_node *tree, char *key, char *valuebuf);
void dict_insert(dictionary_node *tree, char *key, char *value);
void dict_remove(dictionary_node *tree, char *key);

