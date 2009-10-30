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
    prestart)
        exit 0
        ;;
    start)
        sleep 30
        for n in $NODELIST; do
	  echo "CONNECT TO $n  ###############################"
          clickctrl.sh read $n 7777 lt links
        done
	echo "done"
        ;;
    stop)
        exit 0
        ;;
    poststop)
        exit 0
        ;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0

