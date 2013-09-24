all: disk.iso

disk.iso: bootloader.bin kernel.bin
	cat $^ > bootsector.bin.tmp
	dd if=/dev/zero of=$@ bs=512 count=2
	dd if=bootsector.bin.tmp of=$@ conv=notrunc
	rm bootsector.bin.tmp

kernel.bin: entry.o kernel.o
	ld -Ttext 0x1000 --oformat binary -m elf_i386 -o $@ $^

bootloader.bin: bootloader.asm
	nasm $^ -f bin -o $@

entry.o: entry.asm
	nasm $^ -f elf -o $@

kernel.o: kernel.c
	gcc -m32 -ffreestanding -c $^ -o $@

clean:
	rm *.bin *.o
