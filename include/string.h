#pragma once

#include <stddef.h>

size_t strlen(char *str);

void *memcpy(void * restrict dest, const void * restrict src, size_t n);

void *memmove(void *dest, const void *src, size_t n);
