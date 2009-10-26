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

echo "das Script: $1"

case "$1" in
    prestart)
	echo "prestart"
        ;;
    start)
        echo "Start crtl"
        sleep 10
        for n in $NODELIST; do
	  echo "CONNECT TO $n  ###############################"
          clickctrl.sh read $n 7777 lt links
        done
	SRCMAC=`cat $FINALRESULTDIR/nodelist | grep sk110 | awk '{print $3}'`
	DSTMAC=`cat $FINALRESULTDIR/nodelist | grep sk111 | awk '{print $3}'`
	  echo "CONNECT TO sk110  ###############################"
	clickctrl.sh write sk110 7777 sf add_flow \"$SRCMAC $DSTMAC 1000 100 0 2000 1\"
	sleep 2
        echo "CONNECT TO sk110  ###############################"
	clickctrl.sh write sk110 7777 sf active 0
	clickctrl.sh read sk110 7777 sf txflows
	clickctrl.sh read sk110 7777 sf rxflows
	echo "CONNECT TO sk111  ###############################"
	clickctrl.sh read sk111 7777 sf txflows
	clickctrl.sh read sk111 7777 sf rxflows
        ;;
    stop)
        echo "Stop ctrl"
        ;;
    poststop)
	echo "poststop"
	;;
    *)
	echo "Use $0 start|stop"
	;;
esac

exit 0

