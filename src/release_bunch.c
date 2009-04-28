#include <release_bunch.h>
#include <stdlib.h>

typedef struct release_bunch_nodeTAG
{
	void *ptr;
	struct release_bunch_nodeTAG *next;
} release_bunch_node;

typedef struct release_bunch_structTAG
{
	release_bunch_node *head, *tail;
} release_bunch_struct;

release_bunch_node *release_bunch_initnode()
{
	release_bunch_node *node;
	node = malloc(sizeof(release_bunch_node));
	node->ptr = NULL;
	node->next = NULL;
	return node;
}

release_bunch relbunch_create()
{
	release_bunch_struct *bunch = malloc(sizeof(release_bunch_struct));
	bunch->head = bunch->tail = release_bunch_initnode();
	return bunch;
}

void relbunch_add_pointer(release_bunch bunch, void *ptr)
{
	release_bunch_struct *thebunch = bunch;
	thebunch->tail->ptr = ptr;
	thebunch->tail->next = release_bunch_initnode();
	thebunch->tail = thebunch->tail->next;
}

void relbunch_release(release_bunch bunch)
{
	release_bunch_struct *thebunch = bunch;
	while (thebunch->head)
	{
		release_bunch_node *next = thebunch->head->next;
		free(thebunch->head->ptr);
		free(thebunch->head);
		thebunch->head = next;
	}
	free(thebunch);
}

