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

$DIR/sync_dumps.sh $1

case "$1" in
    start)
        echo "killall old stuff"
        killall node_voip_ctrl.sh
	echo "Nodecontrol"
	$DIR/node_voip_ctrl.sh &
	;;
    stop)
        echo "killall nodecontrol"
	killall node_voip_ctrl.sh
	;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0
