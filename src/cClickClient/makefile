CC = g++
AR = ar

LIBSRCS= csclient.cc lzw.cc base64.cc
BINSRCS= click_client.cc click_ctrl.cc


LIBOBJS = $(foreach src, $(LIBSRCS), $(src:.cc=.o))
BINOBJS = $(foreach src, $(BINSRCS), $(src:.cc=.o))

%.o : %.cc
	$(CC) -c $(CFLAGS) $< -o $@

all: libclickctrl.a  $(BINOBJS)
	g++ -o click_client click_client.o -L. -lclickctrl
	g++ -o click_ctrl click_ctrl.o -L. -lclickctrl

libclickctrl.a:  $(LIBOBJS)
	$(AR) r $@ $?

libclickctrl.so:  $(LIBOBJS)
	$(CC) $(CFLAGS) -shared -o $@ -Wl,-soname,$@ $?

clean:
	rm -f *.o click_ctrl csclient *.so *.a
