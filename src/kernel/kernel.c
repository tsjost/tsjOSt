#include <stddef.h>

#include <string.h>

void printString(char *str) {
	char *videomem = (char *) 0xb8000;
	size_t len = strlen(str);
	for (size_t i = 0; i < len; i++)
		videomem[i*2] = str[i];
}

void main() {
	printString("Hello World from the booted C kernel!");
}

