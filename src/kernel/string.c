#include <string.h>

size_t strlen(char *str) {
    size_t len = 0;
    while (*str++)
        len++;
    return len;
}

void *memcpy(void * restrict dest, const void * restrict src, size_t n)
{
	char * restrict dest_c = dest;
	const char * restrict src_c = src;

	for (size_t i = 0; i < n; ++i) {
		dest_c[i] = src_c[i];
	}

	return dest;
}

void *memmove(void *dest, const void *src, size_t n)
{
	// Possibly undefined behaviour
	if (src > dest) {
		return memcpy(dest, src, n);
	} else {
		char *dest_c = dest;
		const char *src_c = src;

		// We can't do >= 0 because unsigned
		for (size_t i = n; i > 0; --i) {
			dest_c[i-1] = src_c[i-1];
		}

		return dest;
	}
}
