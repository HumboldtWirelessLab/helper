CC = g++

SRCS= csclient.cc lzw.cc base64.cc csclient_main.cc click_ctrl.cc

OBJS = $(foreach src, $(SRCS), $(src:.cc=.o))

%.o : %.cc
	$(CC) -c $(CFLAGS) $< -o $@

all:  $(OBJS)
	g++ -o csclient csclient.o csclient_main.o
	g++ -o click_ctrl csclient.o click_ctrl.o lzw.o base64.o
clean:
	rm -f *.o click_ctrl csclient
