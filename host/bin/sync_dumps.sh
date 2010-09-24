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
	SYNCPID=`pidof send_sync`
	echo "Stop old Sync"
	kill -9 $SYNCPID
        echo "Start Sync"
	$DIR/send_sync 60000 192.168.3.2 1 &
	;;
    stop)
	SYNCPID=`pidof send_sync`
	echo "Stop Sync"
	kill -9 $SYNCPID
	;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0
