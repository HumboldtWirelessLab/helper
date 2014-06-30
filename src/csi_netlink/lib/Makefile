all: libcsi.a

KERNEL = $(strip $(shell uname -r))
KERNEL_INCLUDE = -I/usr/src/develop/BerlinRoofNet/csi/linux-80211n-csitool/usr/include
LIBS = -lm
INCLUDES = -I../include
CFLAGS = -Wall -Werror $(KERNEL_INCLUDE) $(INCLUDES)
LDFLAGS = $(LIBS) 
CC = gcc
LD = gcc


libcsi.a: bf_to_eff.o iwl_nl.o util.o q_approx.o
	$(AR) r $@ $?

clean:
	rm -f *.o *.a *~
