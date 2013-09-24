all:
	nasm bootloader.asm -f bin -o bootloader.bin
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o
	ld -Ttext 0x1000 --oformat binary -m elf_i386 kernel.o -o kernel.bin
	cat bootloader.bin kernel.bin > bootsector.bin.tmp
	dd if=/dev/zero of=bootsector.bin bs=512 count=2
	dd if=bootsector.bin.tmp of=bootsector.bin conv=notrunc
	rm bootsector.bin.tmp
