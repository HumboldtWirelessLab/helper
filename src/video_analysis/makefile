all:
	g++ detection.cc -o detection -lopencv_core -lopencv_imgproc -lopencv_objdetect -lopencv_highgui -lopencv_imgproc -lopencv_video -lopencv_core

test: all
	./detection example.avi