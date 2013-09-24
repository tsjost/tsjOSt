#include <stddef.h>

size_t strlen(char *str) {
	size_t len = 0;
	while (*str++)
		len++;
	return len;
}

void printString(char *str) {
	char *videomem = (char *) 0xb8000;
	size_t len = strlen(str);
	for (int i = 0; i < len; i++)
		videomem[i*2] = str[i];
}

void main() {
	printString("Hello World from the booted C kernel!");
}

