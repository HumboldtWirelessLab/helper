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
	SYNCPID=`ssh 192.168.4.117 "pidof send_sync"`
	echo "Stop old Sync"
	ssh 192.168.4.117 "kill -9 $SYNCPID"
        echo "Start Sync"
	scp $DIR/send_sync 192.168.4.117:/tmp
	ssh 192.168.4.117 "/tmp/send_sync 60000 192.168.3.100 30 &"
	;;
    stop)
	SYNCPID=`ssh 192.168.4.117 "pidof send_sync"`
	echo "Stop Sync"
	ssh 192.168.4.117 "kill -9 $SYNCPID"
	;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0
