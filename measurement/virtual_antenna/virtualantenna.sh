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
	echo "Start java"
	(java -jar VirtualAntenna.jar > virtualantenna.log) &
	;;
    stop)
	echo "Stop java"
	killall -s TERM java
	;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0
