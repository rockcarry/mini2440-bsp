# makefile for drivertest

CC=$(shell pwd)/../toolchain/bin/arm-mini2440-linux-gnueabi-gcc
PREFIX=$(shell pwd)/../output/rootfs/opt/drvtest
OUTDIR=$(shell pwd)/out

EXES = \
    ledtest \
    fbtest

all : $(OUTDIR) $(EXES)

$(OUTDIR) :
	mkdir -p $(OUTDIR)

% : %.c
	$(CC) $(CCFLAGS) -o $(OUTDIR)/$@ $<

clean :
	-rm -rf $(OUTDIR)

install : all
	mkdir -p $(PREFIX)
	cp $(OUTDIR)/* $(PREFIX)

uninstall :
	rm -rf $(PREFIX)

