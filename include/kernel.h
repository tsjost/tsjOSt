#pragma once

#include <stdint.h>

static const char scancode2ascii[256] = {
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
	[0x5A] = '\n',
};

struct {
	unsigned char x;
	unsigned char y;
} cursor = {0, 0};

#define GETCHAR_WAITING -1337
#define GETCHAR_NOTWAITING -1234
int getchar_char = GETCHAR_NOTWAITING;
int kernel_getchar();

void printCharAt(char chr, uint8_t color, uint8_t x, uint8_t y);
void printChar(char chr);
void printString(char *str);
void printHex(unsigned int hex);
void handleAsciiCode(char asciicode);
void handleScanCode(unsigned char scancode);
