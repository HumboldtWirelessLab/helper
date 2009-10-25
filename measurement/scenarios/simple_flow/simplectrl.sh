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
        echo "Start crtl"
        sleep 10;
        for n in $NODELIST; do
          clickctrl.sh read $n 7777 lt links
        done
        ;;
    stop)
        echo "Stop ctrl"
        ;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0

