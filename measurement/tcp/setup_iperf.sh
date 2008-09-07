#!/bin/bash

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

case "$SIGN" in
  "/")
      DIR=$dir
      ;;
  ".")
      DIR=$pwd/$dir
      ;;
   *)
      echo "Error while getting directory"
      exit -1
      ;;
esac

case "$1" in
    start)
        echo "Start iperf"
	(ssh gruenau2.informatik.hu-berlin.de iperf -s -p 20000 -D) &
	;;
    stop)
	echo "stop iperf"
	(ssh gruenau2.informatik.hu-berlin.de killall -9 iperf ) &
	;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0
