TOPDIR=$(shell pwd)

export LD_PRELOAD =
CFLAGS := -D_KERNEL -fno-builtin -mips1 -DMEMSTART=0x80000000 -DMEMSIZE=0x04000 -DCPU_COUNT_PER_US=1000 -I $(TOPDIR)/include 
CFLAGS += -fno-reorder-blocks -fno-reorder-functions -EL

OBJDIR = ./obj

export TOPDIR AR CFLAGS
export CROSS_COMPILE ?= mipsel-linux-

all:
	make compile

compile:main.bin main.data convert
	./convert
	mkdir -p $(OBJDIR)
	mv main.elf  $(OBJDIR)/.
	mv test.s    $(OBJDIR)/.
	mv main.bin  $(OBJDIR)/.
	mv main.data $(OBJDIR)/.
	mv *.coe     $(OBJDIR)/.
	mv *.mif     $(OBJDIR)/.

main.bin:main.elf
	${CROSS_COMPILE}objcopy -O binary -j .text $< $@ 

main.data:main.elf
	${CROSS_COMPILE}objcopy -O binary -j .data $< $@ 

main.elf: start.o libinst.a 
	${CROSS_COMPILE}gcc -E -P -Umips -D_LOADER -U_MAIN $(CFLAGS) bin.lds.S -o bin.lds
	${CROSS_COMPILE}ld -g -EL -T bin.lds  -o $@ start.o -L . -linst
	${CROSS_COMPILE}objdump -alD $@ > test.s

libinst.a:
	make -C inst $(TOPDIR)/$@

convert:convert.c
	gcc  $(ALIGNED) -o convert  convert.c

clean:
	rm -f *.o *.a 
	rm -rf obj
	rm -f bin.lds convert
	make -C inst clean

help:
	@echo "################################################################"
	@echo "### help for compiling func"
	@echo "################################################################"
	@echo "### options:"
	@echo "###     make      : get compiled result, which is saved in ./obj"
	@echo "###     make clean: remove *.o, *.a, and ./obj bin.lds convert"
	@echo "###     make help : show help information"
	@echo "###############################################################"

-include rules.make
