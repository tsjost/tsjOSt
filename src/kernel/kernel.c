#include <stddef.h>

#include <string.h>

void printString(char *str) {
	static unsigned char line = 0;
	char *videomem = (char *) 0xb8000 + line*160;
	size_t len = strlen(str);
	for (size_t i = 0; i < len; i++)
		videomem[i*2] = str[i];
	++line;
}

void main() {
	printString("Hello World from the booted C kernel!");
	printString("And here's another line!");
}

