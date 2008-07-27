#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <stdio.h>

#include "dictionary.h"

dictionary_node *talloc()
{
	return ((dictionary_node *) malloc(sizeof(dictionary_node)));
}

dictionary_node *dict_getempty()
{
	dictionary_node *new;
	new = talloc();
	new->key=malloc(1);
	new->value=malloc(1);
	new->left=NULL;
	new->right=NULL;
	return new;
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

		tree->key = malloc(1);
		tree->value = malloc(1);

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

	if (t>=0)
	{
		dict_insert_real(tree->right, key, value, tree, 1);
	}
	else
	{
		dict_insert_real(tree->left, key, value, tree, -1);
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
