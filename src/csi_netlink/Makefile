all: csi_tool

KERNEL = $(strip $(shell uname -r))
LIBS = -L./lib -lcsi -lm
INCLUDES = -I./include
CFLAGS = -Wall -Werror $(INCLUDES)
LDFLAGS = $(LIBS)
CC = gcc
LD = gcc


.PHONY: libcsi.a

libcsi.a:
	(cd lib; make)

csi_tool: csi_tool.o
	$(CC) -o $@ $^ $(LDFLAGS)

clean:
	rm -f csi_tool *.o *~

realclean: clean
	(cd lib; make clean)

test: csi_tool
	./csi_tool mode data/bar.dat data/foo.dat

