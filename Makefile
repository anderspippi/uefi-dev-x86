CFLAGS= -c -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -DEFI_FUNCTION_WRAPPER -I /usr/include/efi -I /usr/include/efi/x86_64/
LDFLAGS= -nostdlib -znocombreloc -T /usr/lib/elf_x86_64_efi.lds -shared -Bsymbolic -L /usr/lib/ -l:libgnuefi.a -l:libefi.a

all: docker

docker:
	docker buildx build --platform linux/amd64 -t uefi-app .
	docker run -v $(shell pwd):/uefi -ti uefi-app

.PHONY: qemu
qemu: c
	ls /uefi
	qemu-system-x86_64 -nographic -m 1G -pflash /usr/share/OVMF/OVMF_CODE.fd -net none -drive file=fat:rw:/uefi

.PHONY: c
c:
	cc main.c $(CFLAGS) -o main.o
	ld main.o /usr/lib/crt0-efi-x86_64.o $(LDFLAGS) -o main.so
	objcopy -j .text -j .sdata -j .data -j .dynamic -j .dynsym -j .rel -j .rela -j .reloc --target=efi-app-x86_64 main.so main.efi 
clean:
	rm -f *.o *.so *.efi NvVars
