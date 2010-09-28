all:
	g++ -c csclient.cc
	g++ -c csclient_main.cc
	g++ -c click_ctrl.cc
	g++ -o csclient csclient.o csclient_main.o
	g++ -o click_ctrl csclient.o click_ctrl.o
clean:
	rm -f *.o click_ctrl csclient
