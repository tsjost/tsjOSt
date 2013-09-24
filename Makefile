all:
	nasm bootloader.asm -f bin -o bootloader.bin
	nasm entry.asm -f elf -o entry.o
	gcc -m32 -ffreestanding -c kernel.c -o kernel.o
	ld -Ttext 0x1000 --oformat binary -m elf_i386 -o kernel.bin entry.o kernel.o
	cat bootloader.bin kernel.bin > bootsector.bin.tmp
	dd if=/dev/zero of=bootsector.bin bs=512 count=2
	dd if=bootsector.bin.tmp of=bootsector.bin conv=notrunc
	rm bootsector.bin.tmp

clean:
	rm bootloader.bin bootsector.bin kernel.bin kernel.o entry.o
