ORG 0x7c00
BITS 16
CPU 386

mov ax, 2
int 0x10

mov si, STR_HELLO
call print_string

mov si, 0x1337
call print_hex

mov si, 0xCAFE
call print_hex

mov si, 0xBABE
call print_hex

mov si, STR_BOOTING
call print_string

jmp $

print_string:
	push ax

	print_string_loop:
	cmp [si], byte 0
	je print_string_end
	mov ah, 0x0e
	mov al, [si]
	int 0x10
	inc si
	jmp print_string_loop

	print_string_end:
	pop ax
	ret

print_hex:
	; Assuming the number we want to print is in SI
	; We're going to loop 4 times and process 4 bits each iteration.
	; By right shifting and ANDing we get the 4 bit integer, which
	;   we can do simple arithmetics on to get the proper ASCII value.
	xor dx, dx ; Loop counter
	.loop:
	mov ax, si
	mov cx, dx
	shl cx, 2 ; Multiply by 4 (we want to shift multiples of 4 bits)
	shr ax, cl ; Shift the number so the 4 bits are least significant
	and ax, 0xf
	cmp al, 9
	jle .loopend
	add al, 7 ; There's an offset between numbers and chars in ASCII
	.loopend:
	add al, 48 ; ASCII 0 is at 48
	mov bx, 3
	sub bx, dx ; Calculate the offset into the string
	           ; (0th number (from right) is 3 into string)
	mov [STR_HEX + bx + 2], al ; Put the ASCII char into the string
	inc dx
	cmp dx, 3
	jle .loop
	.print:

	mov si, STR_HEX
	call print_string

	ret

; Data
STR_HELLO:
	db 'Hello World!', 10, 13, 0
STR_BOOTING:
	db 'Booting Operating System...', 10, 13, 0
STR_HEX:
	db '0x0000', 13,10, 0

times 510-($-$$) db 0
dw 0xaa55

