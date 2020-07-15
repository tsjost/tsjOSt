BITS 32
CPU 386

VIDEOMEM equ 0xb8000

EXTERN main
EXTERN printString
EXTERN printHex
EXTERN handleScanCode

cli

; Set up the PIC to send IRQs to the right offset
mov al, 0x11
out 0x20, al
out 0xA0, al

mov al, 0x70 ; IRQ 0-7 goes on this offset
out 0x21, al
mov al, 0x78 ; and IRQ 8-15 goes here
out 0xA1, al

mov al, 0x04
out 0x21, al
mov al, 0x02
out 0xA1, al

mov al, 0x01
out 0x21, al
out 0xA1, al

; Load interrupt table!
lidt [idt]
sti

; Set up keyboard
setupkeyboard:
; Disable
mov al, 0xAD
out 64h, al
mov al, 0xA7
out 64h, al
; Flush buffer
.wait1:
in al, 64h
bt ax, 0
jnc .endwait1
in al, 60h
jmp .wait1
.endwait1:
; Config byte
mov al, 0x20
out 64h, al
.wait3:
in al, 64h
bt ax, 0
jnc .wait3
in al, 60h
mov bl, al
and bl, 00111100b
mov al, 0x60
out 64h, al
.wait4:
in al, 64h
bt ax, 1
jc .wait4
mov al, bl
out 60h, al
; Self test
mov al, 0xAA
out 64h, al
.wait5:
in al, 64h
bt ax, 0
jnc .wait5
in al, 60h
cmp al, 0x55
je .cont1
push STR_PS2FAIL
call printString
jmp $
.cont1:
; Enable
mov al, 0xAE
out 64h, al
mov al, 0xA8
out 64h, al

; Set scan code set
mov al, 0xF0
out 60h, al
; Read ACK byte
.wait8:
in al, 64h
bt ax, 0
jnc .wait8
in al, 60h ; al == 0xFA on success
; We'd like scan code set 2
mov al, 2
out 60h, al
; Read next ACK byte
.wait9:
in al, 64h
bt ax, 0
jnc .wait9
in al, 60h ; al == 0xFA on success

; Enable interrupt
mov al, 0x20
out 64h, al
.wait6:
in al, 64h
bt ax, 0
jnc .wait6
in al, 60h
mov bl, al
or bl, 11b
mov al, 0x60
out 64h, al
.wait7:
in al, 64h
bt ax, 1
jc .wait7
mov al, bl
out 60h, al

call main

push STR_GOODBYE
call printString

jmp $

print_char_at:
	; Character in DI, x pos in EAX, y pos in EBX

	; = 2 * (80*y + x)
	imul ebx, ebx, 80
	add ebx, eax
	add ebx, ebx

	mov edx, ebx
	inc edx
	mov [VIDEOMEM + ebx], di
	mov [VIDEOMEM + edx], byte 0x07

	ret

print_char:
	; Character in DI
	movzx ax, byte [CURSOR]
	movzx bx, byte [CURSOR+1]
	call print_char_at
	inc ax
	mov byte [CURSOR], al
	ret

print_string:
	; String in SI
	.loop:
	cmp [si], byte 0
	je .end
	mov di, [si]
	call print_char
	inc si
	jmp .loop

	.end:
	ret

handle_keyboard:
	pushad
	mov ebp, esp

	xor eax,eax
	in al, 60h
	push eax
	call handleScanCode
	pop eax

	mov al, 20h
	out 20h, al

	popad
	iret

exception0:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x0
	jmp exception_common
exception1:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x1
	jmp exception_common
exception2:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x2
	jmp exception_common
exception3:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x3
	jmp exception_common
exception4:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x4
	jmp exception_common
exception5:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x5
	jmp exception_common
exception6:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x6
	jmp exception_common
exception7:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x7
	jmp exception_common
int_doublefault:
	pushad
	mov ebp,esp
	sub esp, 8
	push STR_DOUBLEFAULT
	call printString
	mov esp,ebp
	mov al, 20h
	out 20h, al
	popad
	iret
exception9:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x9
	jmp exception_common
exceptionA:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0xA
	jmp exception_common
exceptionB:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0xB
	jmp exception_common
exceptionC:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0xC
	jmp exception_common
exceptionD:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0xD
	jmp exception_common
exceptionE:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0xE
	jmp exception_common
exceptionF:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0xF
	jmp exception_common
exception10:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x10
	jmp exception_common
exception11:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x11
	jmp exception_common
exception12:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x12
	jmp exception_common
exception13:
	pushad
	mov ebp, esp
	sub esp, 8
	push 0x13
	jmp exception_common
exception_common:
	call printHex
	push STR_EXCEPTION
	call printString
	mov esp, ebp
	mov al, 20h
	out 20h, al
	popad
	iret

irq0:
	pushad
	mov al, 20h
	out 20h, al
	popad
	iret
irq1:
	pushad
	mov ebp, esp
	sub esp, 8
	push 1
	jmp irq_common
irq2:
	pushad
	mov ebp, esp
	sub esp, 8
	push 2
	jmp irq_common
irq3:
	pushad
	mov ebp, esp
	sub esp, 8
	push 3
	jmp irq_common
irq4:
	pushad
	mov ebp, esp
	sub esp, 8
	push 4
	jmp irq_common
irq5:
	pushad
	mov ebp, esp
	sub esp, 8
	push 5
	jmp irq_common
irq6:
	pushad
	mov ebp, esp
	sub esp, 8
	push 6
	jmp irq_common
irq7:
	pushad
	mov ebp, esp
	sub esp, 8
	push 7
	jmp irq_common
irq8:
	pushad
	mov ebp, esp
	sub esp, 8
	push 8
	jmp irq_common
irq9:
	pushad
	mov ebp, esp
	sub esp, 8
	push 9
	jmp irq_common
irq10:
	pushad
	mov ebp, esp
	sub esp, 8
	push 10
	jmp irq_common
irq11:
	pushad
	mov ebp, esp
	sub esp, 8
	push 11
	jmp irq_common
irq12:
	pushad
	mov ebp, esp
	sub esp, 8
	push 12
	jmp irq_common
irq13:
	pushad
	mov ebp, esp
	sub esp, 8
	push 13
	jmp irq_common
irq14:
	pushad
	mov ebp, esp
	sub esp, 8
	push 14
	jmp irq_common
irq15:
	pushad
	mov ebp, esp
	sub esp, 8
	push 15
	jmp irq_common
irq_common:
	call printHex
	push STR_IRQ
	call printString
	mov esp, ebp
	mov al, 20h
	out 20h, al
	popad
	iret

; Interrupt Descriptor Table
idt_start:
	dw exception0
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception1
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception2
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception3
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception4
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception5
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception6
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception7
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw int_doublefault
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception9
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exceptionA
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exceptionB
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exceptionC
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exceptionD
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exceptionE
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exceptionF
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception10
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception11
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception12
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw exception13
	dw 0x8
	db 0
	db 10001110b
	dw 0

	; Skip interrupts we don't care about for now
	times 8*(6Fh-13h) db 0x00

	dw irq0
	dw 0x8
	db 0
	db 10001110b
	dw 0

	; 71h = IRQ1 = keyboard
	dw handle_keyboard
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq2
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq3
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq4
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq5
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq6
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq7
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq8
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq9
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq10
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq11
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq12
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq13
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq14
	dw 0x8
	db 0
	db 10001110b
	dw 0

	dw irq15
	dw 0x8
	db 0
	db 10001110b
	dw 0

idt_end:
idt:
	dw idt_end - idt_start
	dd idt_start

CURSOR: dw 0
STR_GOODBYE: db "Goodbye, shutting down!", 0
STR_DOUBLEFAULT: db "DOUBLE FAULT!!!", 0
STR_EXCEPTION: db "EXCEPTION", 0
STR_IRQ: db "IRQ", 0
STR_PS2FAIL: db "PS/2 SELF TEST FAILED!", 0
