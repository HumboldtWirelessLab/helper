all:
	g++ -c csclient.cc
	g++ -c lzw.cc
	g++ -c base64.cc
	g++ -c csclient_main.cc
	g++ -c click_ctrl.cc
	g++ -o csclient csclient.o csclient_main.o
	g++ -o click_ctrl csclient.o click_ctrl.o lzw.o base64.o
clean:
	rm -f *.o click_ctrl csclient
