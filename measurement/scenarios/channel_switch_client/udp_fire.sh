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

echo "call script"

case "$1" in
    start)
        sleep 5
        $DIR/ping.sh
        echo "Start udp fire"
#	$DIR/udp_fire d > $DIR/bla/out.log
	;;
    stop)
	echo "Stop udp"
	killall udp_fire
	;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0
