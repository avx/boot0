/* Alloc.c -- Memory allocation functions
2015-02-21 : Igor Pavlov : Public domain */

#include "Precomp.h"

#include <stdlib.h>

#include "Alloc.h"

#define MALLOC_HEAP_SIZE            20480

static unsigned char lzma_heap[MALLOC_HEAP_SIZE];

/* very simple */
static void *SzAlloc(void *p, size_t size) {
    UNUSED_VAR(p);
    return (void *)lzma_heap;
}

/* don't support freeing of memory = do nothing */
static void SzFree(void *p, void *address) {
    UNUSED_VAR(p);
}

const ISzAlloc g_Alloc = { SzAlloc, SzFree };
