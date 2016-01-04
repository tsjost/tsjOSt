#include <stddef.h>
#include <stdbool.h>

#include <string.h>

static const char scancode2ascii[] = {
	[0x1C] = 'A',
	[0x32] = 'B',
	[0x21] = 'C',
	[0x23] = 'D',
	[0x24] = 'E',
	[0x2B] = 'F',
	[0x34] = 'G',
	[0x33] = 'H',
	[0x43] = 'I',
	[0x3B] = 'J',
	[0x42] = 'K',
	[0x4B] = 'L',
	[0x3A] = 'M',
	[0x31] = 'N',
	[0x44] = 'O',
	[0x4D] = 'P',
	[0x15] = 'Q',
	[0x2D] = 'R',
	[0x1B] = 'S',
	[0x2C] = 'T',
	[0x3C] = 'U',
	[0x2A] = 'V',
	[0x1D] = 'W',
	[0x22] = 'X',
	[0x35] = 'Y',
	[0x1A] = 'Z',
};

void printString(char *str) {
	static unsigned char line = 0;
	unsigned char display_line = line % 25;
	char *videomem_start = (char *) 0xb8000;
	char *videomem = videomem_start + display_line*160;
	size_t len = strlen(str);
	for (size_t i = 0; i < len; i++) {
		videomem[4+ i*2+1] = 0x07;
		videomem[4+ i*2] = str[i];
	}

	for (size_t i = 0; i < 25; ++i) {
		videomem_start[0 + i*160] = ' ';
		videomem_start[0 + i*160+1] = 0x00;
	}
	videomem[0] = '>';
	videomem[0+1] = 0xF0;

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

void handleAsciiCode(unsigned char asciicode) {
	char str[] = "0";
	str[0] = asciicode;
	printString(str);
}
void handleScanCode(unsigned char scancode) {
	static bool is_break = false;
	static unsigned char prev_scancode = 0;
	if (0xF0 == scancode) {
		is_break = true;
		return;
	}
	if (0xE0 == scancode) {
		prev_scancode = scancode;
		return;
	}

	if ( ! is_break) {
		handleAsciiCode(scancode2ascii[scancode]);
	}
	is_break = false;
	prev_scancode = 0;
}

void main() {
	printString("Hello World from the booted C kernel!");
	printString("And here's another line!");

	printHex(0xDEADBEEF);
}

