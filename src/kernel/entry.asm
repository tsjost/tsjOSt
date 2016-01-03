BITS 32
CPU 386

EXTERN main
EXTERN printString

call main

push STR_GOODBYE
call printString

jmp $

STR_GOODBYE: db "Goodbye, shutting down!", 0
