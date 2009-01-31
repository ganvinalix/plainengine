#ifndef __RELEASE_BUNCH__
#define __RELEASE_BUNCH__

/**
  Release bunch is data structure than contains a list of pointers,
  and frees them on release.
  (Useful, when you need to allocate many memory blocks
  and free all of them after.)
  */
typedef void* release_bunch;

/** Creates release bunch */
release_bunch relbunch_create();
/** Adds pointer ptr to bunch */
void relbunch_add_pointer(release_bunch bunch, void *ptr);
/** Frees memory, used by bunch and all pointers, added to bunch */
void relbunch_release(release_bunch bunch);

#endif //__RELEASE_BUNCH__

