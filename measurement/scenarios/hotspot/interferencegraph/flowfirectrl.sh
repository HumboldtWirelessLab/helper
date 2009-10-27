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
	        echo "############################### Setup single Flow on $n ###############################"
	        #start end paketsize bw
          clickctrl.sh write $n 7777 qc flow_insert 1000 3000 1500 1
          sleep 5
	        echo "######################### Read stats for single Flow on $n ############################"
          clickctrl.sh read $n 7777 qc flow_stats
          sleep 1
        done
	
	      for s in $NODELIST; do
	        for d in $NODELIST; do
	          if [ "x$s" != "x$d" ]; then
     	        echo "############################### Setup Flows on $n and $m ###############################"
	            #start end paketsize bw
              clickctrl.sh write $n 7777 qc flow_insert 1000 3000 1500 1
              clickctrl.sh write $m 7777 qc flow_insert 1000 3000 1500 1
              sleep 5
              echo "######################### Read stats for Flows on $n and $m ############################"
              clickctrl.sh read $n 7777 qc flow_stats
              clickctrl.sh read $m 7777 qc flow_stats
              sleep 1
            fi
          done
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

