#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "dictionary.h"

dictionary_node *talloc(unsigned long keylength, unsigned long valuelength)
{
	dictionary_node* dict;
	dict = ((dictionary_node *) malloc(sizeof(dictionary_node)));
	dict->key = malloc(keylength);
	dict->value = malloc(valuelength);
	dict->left = NULL;
	dict->right = NULL;

	return dict;
}

dictionary *dict_getempty()
{
	dictionary *dict;
	dict = malloc(sizeof(dictionary));
	dict->root = talloc(0, 0);
	dict->size = 0;
	dict->ismutable = 1;
	return dict;
}

long unsigned dict_size(dictionary *tree)
{
	if (!tree)
	{
		return 0;
	}
	return tree->size;
}

int dict_find_real(dictionary_node *tree, const char *key, char *valuebuf)
{
	if (!tree)
	{
		return 0;
	}
	int t;
	t = strcmp(key, tree->key);
	
	if (t==0)
	{
		if (valuebuf)
		{
			strcpy(valuebuf, tree->value);
		}
		return 1;
	}
	else if (t<0)
	{
		return dict_find_real(tree->left, key, valuebuf);
	}
	else /*if (t>0)*/
	{
		return dict_find_real(tree->right, key, valuebuf);
	}
}

int dict_find(dictionary *tree, const char *key, char *valuebuf)
{
	if (!tree)
	{
		return 0;
	}
	return dict_find_real(tree->root, key, valuebuf);
}

int dict_insert_real(dictionary_node *tree, const char *key, const char *value, dictionary_node *prev, int direction)
{
	if (!tree)
	{
		tree = talloc(strlen(key), strlen(value));

		strcpy(tree->key, key);
		strcpy(tree->value, value);
		tree->left = NULL;
		tree->right = NULL;

		if (prev)
		{
			if (direction<0)
			{
				prev->left = tree;
			}
			else if (direction>0)
			{
				prev->right = tree;
			}
		}
		return 1;
	}

	int t;
	t = strcmp(key, tree->key);

	if (t>0)
	{
		return dict_insert_real(tree->right, key, value, tree, 1);
	}
	else if (t<0)
	{
		return dict_insert_real(tree->left, key, value, tree, -1);
	}
	else /*if (t==0)*/
	{
		strcpy(tree->value, value);
		return 0;
	}
}


void dict_insert(dictionary *tree, const char *key, const char *value)
{
	if (!tree)
	{
		return;
	}
	if (!(tree->ismutable))
	{
		return;
	}
	tree->size += dict_insert_real(tree->root, key, value, NULL, 0);
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

int dict_remove_real(dictionary_node *tree, const char *key, dictionary_node *parent, int direction)
{
	if (!tree)
	{
		return 0;
	}

	int t;
	t = strcmp(key, tree->key);

	if (t>0)
	{
		return dict_remove_real(tree->right, key, tree, 1);
	}
	else if (t<0)
	{
		return dict_remove_real(tree->left, key, tree, -1);
	}
	else /*if (t==0)*/
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
			(*par)->left = m->right; /* (*par)->left surely contains link to m */
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
			if (direction<0)
			{
				parent->left = NULL;
			}
			else if (direction>0)
			{
				parent->right = NULL;
			}
			return 1;
		}
	}
}

void dict_remove(dictionary *tree, const char *key)
{
	if (!tree)
	{
		return;
	}
	if (!(tree->ismutable))
	{
		return;
	}
	tree->size -= dict_remove_real(tree->root, key, NULL, 0);
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

void dict_clear(dictionary *tree)
{	
	if (!tree)
	{
		return;
	}
	if (!(tree->ismutable))
	{
		return;
	}
	dict_clear_real(tree->root);
	tree->root = talloc(0, 0); /* TODO: Optimize later */
	tree->size = 0;
}

void dict_free(dictionary *tree)
{
	if (!tree)
	{
		return;
	}
	dict_clear_real(tree->root);
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

dictionary *dict_copy(dictionary *source)
{
	if (!source)
	{
		return NULL;
	}
	dictionary *new;
	new = malloc(sizeof(dictionary));
	new->size = source->size;
	new->ismutable = 1;
	new->root = dict_copy_real(source->root);
	return new;
}

void dict_close(dictionary *tree)
{
	if (!tree)
	{
		return;
	}
	tree->ismutable = 0;
}

void dict_key_fill_enumerator(dict_enumerator_data **cur, dictionary_node *tree)
{
	if (!tree)
	{
		(*cur)->next = NULL;
		return;
	}
	dict_enumerator_data *dat;
	(*cur)->next = malloc(sizeof(dict_enumerator_data));
	dat = (*cur)->next;
	dat->val = malloc(0);
	strcpy(dat->val, tree->key);
	(*cur) = dat;
	dict_key_fill_enumerator(cur, tree->left);
	dict_key_fill_enumerator(cur, tree->right);
}

dict_enumerator *dict_get_keyenumerator(dictionary *tree)
{
	if (!tree)
	{
		return NULL;
	}
	dict_enumerator *newenumer;
	newenumer = malloc(sizeof(dict_enumerator));
	dict_enumerator_data *first, *cur;
	first = malloc(sizeof(dict_enumerator_data));
	cur = first;
	dict_key_fill_enumerator(&cur, tree->root->left);
	dict_key_fill_enumerator(&cur, tree->root->right);
	cur = first;
	first = first->next;
	free(cur);
	/* Any other way is even worser than this. Let it be so. */
	newenumer->first = newenumer->current = first;

	return newenumer; //!!! is it ok? (by nekro)
}

void dict_value_fill_enumerator(dict_enumerator_data **cur, dictionary_node *tree)
{
	if (!tree)
	{
		(*cur)->next = NULL;
		return;
	}
	dict_enumerator_data *dat;
	(*cur)->next = malloc(sizeof(dict_enumerator_data));
	dat = (*cur)->next;
	dat->val = malloc(0);
	strcpy(dat->val, tree->value);
	(*cur) = dat;
	dict_value_fill_enumerator(cur, tree->left);
	dict_value_fill_enumerator(cur, tree->right);
}

dict_enumerator *dict_get_valueenumerator(dictionary *tree)
{
	if (!tree)
	{
		return NULL;
	}
	dict_enumerator *newenumer;
	newenumer = malloc(sizeof(dict_enumerator));
	dict_enumerator_data *first, *cur;
	first = malloc(sizeof(dict_enumerator_data));
	cur = first;
	dict_value_fill_enumerator(&cur, tree->root->left);
	dict_value_fill_enumerator(&cur, tree->root->right);
	cur = first;
	first = first->next;
	free(cur);
	/* Any other way is even worser than this. Let it be so. */
	newenumer->first = newenumer->current = first;

	return newenumer; //!!! is it ok? (by nekro)
}


char *dict_enumerator_next(dict_enumerator *enumerator)
{
	if (!enumerator)
	{
		return NULL;
	}
	if (!(enumerator->current))
	{
		return NULL;
	}
	char *c;
	c = enumerator->current->val;
	enumerator->current = enumerator->current->next;
	return c;
}

void dict_free_enumerator_data(dict_enumerator_data *data)
{
	if (!data)
	{
		return;
	}
	dict_enumerator_data *next;
	free(data->val);
	next = data->next;
	free(data);
	dict_free_enumerator_data(next);
}

void dict_free_enumerator(dict_enumerator *enumerator)
{
	if (!enumerator)
	{
		return;
	}
	dict_free_enumerator_data(enumerator->first);
	free(enumerator);
}

