#include <stddef.h>

#include <string.h>

void printString(char *str) {
	static unsigned char line = 0;
	unsigned char display_line = line % 25;
	char *videomem = (char *) 0xb8000 + display_line*160;
	size_t len = strlen(str);
	for (size_t i = 0; i < len; i++) {
		videomem[i*2+1] = 0x07;
		videomem[i*2] = str[i];
	}
	++line;
}

void printHex(unsigned int hex) {
	static int iters = 0;
	char hex_str[] = "0x00000000";

	for (int i = 9; i >= 2; --i) {
		unsigned char nibble = hex & 0xF;
		char hex_chr = '0' + nibble;
		if (nibble > 9) {
			hex_chr += 7;
		}
		hex_str[i] = hex_chr;
		hex /= 16;
	}
	printString(hex_str);

	++iters;
}

void main() {
	printString("Hello World from the booted C kernel!");
	printString("And here's another line!");

	printHex(0xDEADBEEF);
}

