#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <stdio.h>

#include "dictionary.h"

dictionary_node *talloc()
{
	dictionary_node* dict;
	dict = ((dictionary_node *) malloc(sizeof(dictionary_node)));
	dict->key = malloc(1);
	dict->value = malloc(1);
}

dictionary_node *dict_getempty()
{
	dictionary_node *new;
	new = talloc();
	new->left=NULL;
	new->right=NULL;
	return new;
}

void dict_size_real(dictionary_node *tree, int *counter)
{
	if (!tree)
	{
		return;
	}
	++(*counter);
	dict_size_real(tree->left, counter);
	dict_size_real(tree->right, counter);
}

int dict_size(dictionary_node *tree)
{
	int counter=-1;
	dict_size_real(tree, &counter);
	return counter;
}

int dict_find(dictionary_node *tree, char *key, char *valuebuf)
{
	if (!tree)
	{
		return 0;
	}
	int t;
	t = strcmp(key, tree->key);
	if (t==0)
	{
		strcpy(valuebuf, tree->value);
		return 1;
	}
	else if (t<0)
	{
		return dict_find(tree->left, key, valuebuf);
	}
	else if (t>0)
	{
		return dict_find(tree->right, key, valuebuf);
	}
	/*OMG WTF???*/
	return 0;
}

void dict_insert_real(dictionary_node *tree, char *key, char *value, dictionary_node *prev, int direction)
{
	if (!tree)
	{
		tree = talloc();

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
		return;
	}

	int t;
	t = strcmp(key, tree->key);

	if (t>0)
	{
		dict_insert_real(tree->right, key, value, tree, 1);
	}
	else if (t<0)
	{
		dict_insert_real(tree->left, key, value, tree, -1);
	}
	else
	{
		strcpy(tree->value, value);
	}

}


void dict_insert(dictionary_node *tree, char *key, char *value)
{
	dict_insert_real(tree, key, value, NULL, 0);
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

void dict_remove_real(dictionary_node *tree, char *key, dictionary_node *parent, int direction)
{
	if (!tree)
	{
		return;
	}

	int t;
	t = strcmp(key, tree->key);

	if (t>0)
	{
		dict_remove_real(tree->right, key, tree, 1);
	}
	else if (t<0)
	{
		dict_remove_real(tree->left, key, tree, -1);
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
			(*par)->left = m->right; /* (*par)->left surely contains link to m */
			free(par);
			free(m);

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
			return;
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
		}
	}
}

void dict_remove(dictionary_node *tree, char *key)
{
	dict_remove_real(tree, key, NULL, 0);
}

void dict_clear(dictionary_node *tree)
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
	dict_clear(l);
	dict_clear(r);
}

dictionary_node *dict_copy(dictionary_node *source)
{
	if (!source)
	{
		return NULL;
	}
	dictionary_node *newnode;
	newnode = talloc();
	strcpy(newnode->key, source->key);
	strcpy(newnode->value, source->value);
	newnode->left = dict_copy(source->left);
	newnode->right = dict_copy(source->right);
	return newnode;
}

