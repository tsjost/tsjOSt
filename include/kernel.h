#pragma once

#include <stdint.h>

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
