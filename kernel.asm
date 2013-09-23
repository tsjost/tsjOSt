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
	lea di, [STR_HEX + 5]
	xor dx, dx
	.loop:
	mov ax, si
	mov cx, dx
	shl cx, 2
	shr ax, cl
	and ax, 0xf
	cmp al, 9
	jle .loopend
	add al, 7
	.loopend:
	add al, 48
	mov bx, 3
	sub bx, dx
	mov [STR_HEX + bx + 2], al
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

