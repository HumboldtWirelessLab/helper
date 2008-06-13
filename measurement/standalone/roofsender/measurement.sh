#!/bin/sh

case "$1" in
    "start")
	./device.sh start
	./click-align ../config/sender.click | ./click
	;;
    "stop")
	killall click
	./device.sh stop
	;;
    *)
	echo "use $0 start | stop"
	;;
esac

exit 0
