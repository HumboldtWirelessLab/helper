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
        sleep 10
        for n in $NODELIST; do
	  echo "CONNECT TO $n  ###############################"
          clickctrl.sh read $n 7777 lt links
        done
	
	for s in $NODELIST; do
	  for d in $NODELIST; do
	    if [ "x$s" != "x$d" ]; then
	      SRCMAC=`cat $FINALRESULTDIR/nodelist | grep $s | awk '{print $3}'`
	      DSTMAC=`cat $FINALRESULTDIR/nodelist | grep $d | awk '{print $3}'`
	      
	      echo "CONNECT TO $s  ###############################"
	      clickctrl.sh write $s 7777 sf add_flow $SRCMAC $DSTMAC 1000 100 0 4000 1
	      sleep 5
	      
              echo "CONNECT TO $s  ###############################"
	      clickctrl.sh write $s 7777 sf active 0
	      clickctrl.sh read $s 7777 sf txflows
#	      clickctrl.sh read $s 7777 sf rxflows
	      echo "CONNECT TO $d  ###############################"
#	      clickctrl.sh read $d 7777 sf txflows
	      clickctrl.sh read $d 7777 sf rxflows
	    fi
	  done
	done
	echo "RXFlows"
	for s in $NODELIST; do
	  clickctrl.sh read $s 7777 sf rxflows
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

