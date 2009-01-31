#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "dictionary.h"

/** Internal structure. Don't use! */
typedef struct tagDN 
{
	char *key, *value;
	struct tagDN *left, *right;
	long unsigned buflen;
} dictionary_node;

/** Dictionary structure. Use only as pointer. WARNING: Never work directly with structure contents! */
typedef struct tagD
{
	int ismutable;
	dictionary_node *root;
	long unsigned size;
	long unsigned maxvaluelength;
} dictionary_struct;

/** Internal structure. Don't use! */
typedef struct tagDED
{
	char const *val;
	struct tagDED *next;
} dict_enumerator_data;

/** Dictionary enumerator structure. Use only as pointer. WARNING: Never work directly with structure contents! */
typedef struct tagDE
{
	dict_enumerator_data *first;
	dict_enumerator_data *current;
} dict_enumerator_struct;



dictionary_node *talloc(unsigned long keylength, unsigned long valuelength)
{
	dictionary_node *dict;
	dict = malloc(sizeof(dictionary_node));
	dict->key = malloc(keylength+1);
	dict->value = malloc(valuelength+1);
	dict->left = NULL;
	dict->right = NULL;
	dict->buflen = valuelength;

	return dict;
}

dictionary dict_getempty()
{
	dictionary_struct *dict;
	dict = malloc(sizeof(dictionary_struct));
	dict->root = talloc(1, 1);
	dict->root->key[0] = '\0';
	dict->root->value[0] = '\0';
	dict->size = 0;
	dict->maxvaluelength = 0;
	dict->ismutable = 1;
	return dict;
}

long unsigned dict_size(dictionary tree)
{
	if (!tree)
	{
		return 0;
	}
	return ((dictionary_struct*)tree)->size;
}

long unsigned dict_maxvaluelength(dictionary tree)
{
	if (!tree)
	{
		return 0;
	}
	return ((dictionary_struct*)tree)->maxvaluelength;
}

char const *dict_find_real(dictionary_node *tree, const char *key)
{
	if (!tree)
	{
		return NULL;
	}
	int t;
	t = strcmp(key, tree->key);
	
	if (t==0)
	{
		return tree->value;
	}
	else if (t<0)
	{
		return dict_find_real(tree->left, key);
	}
	else
	{
		return dict_find_real(tree->right, key);
	}
}

char const *dict_find(dictionary tree, const char *key)
{
	if (!tree)
	{
		return NULL;
	}
	return dict_find_real(((dictionary_struct*)tree)->root, key);
}

int dict_insert_real(dictionary_node *tree, const char *key, const char *value, dictionary_node **prev)
{
	if (!tree)
	{
		if (prev)
		{
			tree = talloc(strlen(key), strlen(value));

			strcpy(tree->value, value);
			strcpy(tree->key, key);

			*prev = tree;
		}
		return 1;
		
	}

	int t;
	t = strcmp(key, tree->key);

	if (t>0)
	{
		return dict_insert_real(tree->right, key, value, &tree->right);
	}
	else if (t<0)
	{
		return dict_insert_real(tree->left, key, value, &tree->left);
	}
	else 
	{
		/* If MEMORY, allocated for tree->value is not long enough, reallocate it */
		unsigned len;
		len = strlen(value);
		if (tree->buflen < len)
		{
			tree->value = realloc(tree->value, len+1);
			tree->buflen = len;
		}
		strcpy(tree->value, value);
		return 0;
	}
}

int dict_insert(dictionary tree, const char *key, const char *value)
{
	if (!tree)
	{
		return -1;
	}
	if (!(((dictionary_struct*)tree)->ismutable))
	{
		return -1;
	}
	long unsigned vl;
	vl = strlen(value);
	if (((dictionary_struct*)tree)->maxvaluelength < vl)
	{
		((dictionary_struct*)tree)->maxvaluelength = vl;
	}
	int res;
	res = dict_insert_real(((dictionary_struct*)tree)->root, key, value, NULL);
	((dictionary_struct*)tree)->size += res;
	return res;
}

dictionary_node* dict_get_leftest(dictionary_node *tree, dictionary_node **parent)
{
	if (!(tree->left))
	{
		return tree;
	}
	(*parent) = tree;
	return dict_get_leftest(tree->left, parent);
}

int dict_remove_real(dictionary_node *tree, const char *key, dictionary_node *parent, dictionary_node **removing)
{
	if (!tree)
	{
		return 0;
	}

	int t;
	t = strcmp(key, tree->key);

	if (t>0)
	{
		return dict_remove_real(tree->right, key, tree, &tree->right);
	}
	else if (t<0)
	{
		return dict_remove_real(tree->left, key, tree, &tree->left);
	}
	else 
	{
		if (tree->left && tree->right)
		{
			dictionary_node *m;
			dictionary_node **par;
			par = malloc(sizeof(dictionary_node *));
			(*par) = tree;
			m = dict_get_leftest(tree->right, par);
			free(tree->key);
			free(tree->value);
			tree->key = m->key;
			tree->value = m->value;
			tree->buflen = m->buflen;
			(*par)->left = m->right; /* (*par)->left surely contains pointer to m */
			tree->right = NULL;
			free(par);
			free(m);
			return 1;

		}
		else if (tree->left || tree->right)
		{
			dictionary_node *old;
			if (tree->left)
			{
				old = tree->left;
			}
			else
			{
				old = tree->right;
			}
			free(tree->key);
			free(tree->value);
			tree->key = old->key;
			tree->value = old->value;
			tree->left = old->left;
			tree->right = old->right;
			free(old);
			return 1;
		}
		else
		{
			free(tree);
			*removing = NULL;
			return 1;
		}
	}
}

int dict_remove(dictionary tree, const char *key)
{
	if (!tree)
	{
		return -1;
	}
	if (!(((dictionary_struct*)tree)->ismutable))
	{
		return -1;
	}
	int res;
	res = dict_remove_real(((dictionary_struct*)tree)->root, key, NULL, 0);
	((dictionary_struct*)tree)->size -= res;
	return res;
}

void dict_clear_real(dictionary_node *tree)
{
	if (!tree)
	{
		return;
	}
	dictionary_node *l, *r;
	l = tree->left;
	r = tree->right;
	free(tree->key);
	free(tree->value);
	free(tree);
	dict_clear_real(l);
	dict_clear_real(r);
}

void dict_clear(dictionary tree)
{	
	if (!tree)
	{
		return;
	}
	if (!(((dictionary_struct*)tree)->ismutable))
	{
		return;
	}
	dict_clear_real(((dictionary_struct*)tree)->root->left);
	dict_clear_real(((dictionary_struct*)tree)->root->right);
	((dictionary_struct*)tree)->root->left = NULL;
	((dictionary_struct*)tree)->root->right = NULL;
	
	((dictionary_struct*)tree)->size = 0;
	((dictionary_struct*)tree)->maxvaluelength = 0;
}

void dict_free(dictionary tree)
{
	if (!tree)
	{
		return;
	}
	dict_clear_real(((dictionary_struct*)tree)->root);
	free(tree);
}

dictionary_node *dict_copy_real(dictionary_node *source)
{
	if (!source)
	{
		return NULL;
	}
	dictionary_node *newnode;
	newnode = talloc(strlen(source->key), strlen(source->value));
	strcpy(newnode->key, source->key);
	strcpy(newnode->value, source->value);
	newnode->left = dict_copy_real(source->left);
	newnode->right = dict_copy_real(source->right);
	return newnode;
}

dictionary dict_copy(dictionary source)
{
	if (!source)
	{
		return NULL;
	}
	dictionary_struct *new;
	new = malloc(sizeof(dictionary_struct*));
	new->size = ((dictionary_struct*)source)->size;
	new->maxvaluelength = ((dictionary_struct*)source)->maxvaluelength;
	new->ismutable = 1;
	new->root = dict_copy_real(((dictionary_struct*)source)->root);
	return new;
}

void dict_close(dictionary tree)
{
	if (!tree)
	{
		return;
	}
	((dictionary_struct*)tree)->ismutable = 0;
}

void dict_key_fill_enumerator(dict_enumerator_data **cur, dictionary_node *tree)
{
	if (!tree)
	{
		(*cur)->next = NULL;
		return;
	}
	dict_key_fill_enumerator(cur, tree->left);
	dict_enumerator_data *dat;
	(*cur)->next = malloc(sizeof(dict_enumerator_data));
	dat = (*cur)->next;
	dat->val = tree->key;
	(*cur) = dat;
	dict_key_fill_enumerator(cur, tree->right);
}

dict_enumerator dict_get_keyenumerator(dictionary tree)
{
	if (!tree)
	{
		return NULL;
	}
	dict_enumerator_struct *newenumer;
	newenumer = malloc(sizeof(dict_enumerator_struct));
	dict_enumerator_data *first, *cur;
	first = malloc(sizeof(dict_enumerator_data));
	cur = first;
	dict_key_fill_enumerator(&cur, ((dictionary_struct*)tree)->root->left);
	dict_key_fill_enumerator(&cur, ((dictionary_struct*)tree)->root->right);
	cur = first;
	first = first->next;
	free(cur);
	/* Any other way is even worser than this. Let it be so. */
	newenumer->first = newenumer->current = first;

	return newenumer; 
}

void dict_value_fill_enumerator(dict_enumerator_data **cur, dictionary_node *tree)
{
	if (!tree)
	{
		(*cur)->next = NULL;
		return;
	}
	dict_value_fill_enumerator(cur, tree->left);
	dict_enumerator_data *dat;
	(*cur)->next = malloc(sizeof(dict_enumerator_data));
	dat = (*cur)->next;
	dat->val = tree->value;
	(*cur) = dat;
	dict_value_fill_enumerator(cur, tree->right);
}

dict_enumerator dict_get_valueenumerator(dictionary tree)
{
	if (!tree)
	{
		return NULL;
	}
	dict_enumerator_struct *newenumer;
	newenumer = malloc(sizeof(dict_enumerator_struct));
	dict_enumerator_data *first, *cur;
	first = malloc(sizeof(dict_enumerator_data));
	cur = first;
	dict_value_fill_enumerator(&cur, ((dictionary_struct*)tree)->root->left);
	dict_value_fill_enumerator(&cur, ((dictionary_struct*)tree)->root->right);
	cur = first;
	first = first->next;
	free(cur);
	/* Any other way is even worser than this. Let it be so. */
	newenumer->first = newenumer->current = first;

	return newenumer;
}

char const *dict_enumerator_next(dict_enumerator enumerator)
{
	if (!enumerator)
	{
		return NULL;
	}
	if (!(((dict_enumerator_struct*)enumerator)->current))
	{
		return NULL;
	}
	char const *c;
	c = ((dict_enumerator_struct*)enumerator)->current->val;
	((dict_enumerator_struct*)enumerator)->current = ((dict_enumerator_struct*)enumerator)->current->next;
	return c;
}

void dict_free_enumerator_data(dict_enumerator_data *data)
{
	if (!data)
	{
		return;
	}
	dict_enumerator_data *next;
	next = data->next;
	free(data);
	dict_free_enumerator_data(next);
}

void dict_free_enumerator(dict_enumerator enumerator)
{
	if (!enumerator)
	{
		return;
	}
	dict_free_enumerator_data(((dict_enumerator_struct*)enumerator)->first);
	free(enumerator);
}

