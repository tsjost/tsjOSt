; BIOS looks for the magic number 0x55 0xAA at the end of the 1st sector (which is 512 bytes big) of each drive,
; and if found, loads that sector into address 0x7c00
ORG 0x7c00 ; Telling the assembler that we know this code will get loaded into address 0x7c00
; Generate 16 bit code please
BITS 16
; CPU instruction set is 386
CPU 386

; Define constant of the RAM location that we're gonna load the kernel into.
KERNEL_OFFSET equ 0x1000

; The only thing guaranteed at this point is that BIOS gives us, in the DL register,
; the "drive number" that the current code was found on,
; so that we can ask BIOS to load more data from the same drive later.
mov [BOOT_DRIVE], dl

;;; Clear screen
;;; BIOS 10h interrupt (Set Video Mode)
;;; AH = 00
;;; AL = 02 --> 80x25 16 shades of grey text
mov ax, 2
int 0x10

mov si, STR_HELLO
call print_string

call load_kernel

; Go into protected mode
cli
lgdt [gdt_descriptor]
mov eax, cr0
or eax, 0x1
mov cr0, eax
jmp CODE_SEG:init_protected_mode

load_kernel:
	mov si, STR_BOOTING
	call print_string

	; Let's load the kernel stuff into RAM
	mov bx, KERNEL_OFFSET ; Data read from drive goes into address pointed to by ES:BX
	mov dh, 10 ; How many sectors we want to read
	mov dl, [BOOT_DRIVE] ; Which drive to read from
	call disk_load

	ret

disk_load:
	push dx

	;;; BIOS 13h interrupt (Disk Services)
	;;; AH = 2 (Read disk sectors)
	;;; AL = number of sectors to read
	;;; CH = track/cylinder number
	;;; CL = sector number
	;;; DH = head number
	;;; DL = drive number
	;;; ES:[BX] = where to store data
	;;; returning:
	;;; AH = status code
	;;; AL = number of sectors read
	;;; CF = 0 on success, 1 on error
	mov ah, 0x02
	mov al, dh
	mov ch, 0x00
	mov cl, 0x02
	mov dh, 0x00
	int 0x13

	jc .error ; carry flag set on error

	pop dx
	cmp dh, al ; AL gets number of sectors actually read
	jne .error_sectors_not_same
	ret

	.error:
	mov si, STR_DISK_ERROR
	call print_string
	mov si, ax ; AH contains the status code
	call print_hex
	jmp $

	.error_sectors_not_same:
	mov si, STR_DISK_ERROR_SECTORS_NOT_SAME
	call print_string
	jmp $

print_string:
	push ax

	.loop:
	cmp [si], byte 0
	je .end
	mov ah, 0x0e
	mov al, [si]
	int 0x10
	inc si
	jmp .loop

	.end:
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

; 32 bit protected mode!
BITS 32
init_protected_mode:
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000
	mov esp, ebp

	jmp start_protected_mode

start_protected_mode:
	mov si, STR_HELLO_PROTECTED
	call print_string_protected

	call KERNEL_OFFSET

	jmp $

print_string_protected:
	pusha

	mov edx, 0xb8000
	.loop:
	cmp [si], byte 0
	je .end
	mov ah, 0x0f
	mov al, [si]
	mov [edx], ax
	inc si
	add edx, 2
	jmp .loop

	.end:
	popa
	ret

; Data

; Global Descriptor Table
gdt_start:
gdt_null:
	dd 0x0
	dd 0x0
gdt_code:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0
gdt_data:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0
gdt_end:
gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

BOOT_DRIVE: db 0

STR_HELLO:
	db 'Hello World!', 10,13,0
STR_HELLO_PROTECTED:
	db "Hello World from Protected Mode!", 0
STR_BOOTING:
	db 'Booting Operating System...', 10,13,0
STR_HEX:
	db '0x0000', 13,10,0
STR_DISK_ERROR:
	db "Could not read from disk!", 13,10,0
STR_DISK_ERROR_SECTORS_NOT_SAME:
	db "Could not read the specified amount of sectors from disk!", 13,10,0

times 510-($-$$) db 0
dw 0xaa55

