all: disk.iso

C_SOURCES = $(wildcard src/kernel/*.c)
C_OBJECTS = ${C_SOURCES:.c=.o}

CFLAGS = -m32 -ffreestanding -Iinclude -std=c11 \
	-Wall \
	-Wextra \
	-pedantic \
	-Wcast-align \
	-Wcast-qual \
	-Wdisabled-optimization \
	-Wformat=2 \
	-Winit-self \
	-Wjump-misses-init \
	-Wlogical-op \
	-Wmissing-declarations \
	-Wmissing-include-dirs \
	-Wredundant-decls \
	-Wshadow \
	-Wsign-conversion \
	-Wstrict-overflow=5 \
	-Wswitch-default \
	-Wundef \
	-fno-pie \
	-fno-stack-protector

disk.iso: bootloader.bin kernel.bin
	cat $^ > bootsector.bin.tmp
	dd if=/dev/zero of=$@ bs=512 count=2
	dd if=bootsector.bin.tmp of=$@ conv=notrunc
	rm bootsector.bin.tmp

kernel.bin: entry.o ${C_OBJECTS}
	ld -Ttext 0x1000 --oformat binary -m elf_i386 -o $@ $^

bootloader.bin: src/boot/bootloader.asm
	nasm $^ -f bin -o $@

entry.o: src/kernel/entry.asm
	nasm $^ -f elf -o $@

%.o: %.c
	gcc -c $^ -o $@ $(CFLAGS)

clean:
	rm *.bin *.o src/kernel/*.o
