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
          clickctrl.sh write $n 7777 qc flow_insert "1000 11000 1200 4"
          sleep 15
	        echo "######################### Read stats for single Flow on $n ############################"
         RAWSTATS=`clickctrl.sh read $n 7777 qc flow_stats`
	 echo $RAWSTATS
	 STATS=`echo $RAWSTATS | grep "Rate" | awk '{print $4}'`
	 echo "$n none $STATS none" >> $FINALRESULTDIR/ig.stats
         clickctrl.sh read $n 7777 cnt count
         clickctrl.sh read $n 7777 cnt byte_count
         clickctrl.sh write $n 7777 cnt reset "1"
         sleep 1
        done
	
	      for n in $NODELIST; do
	        for m in $NODELIST; do
	          if [ "x$n" != "x$m" ]; then
     	        echo "############################### Setup Flows on $n and $m ###############################"
	            #start end paketsize bw
              clickctrl.sh write $n 7777 qc flow_insert "1000 3000 1200 4"
              clickctrl.sh write $m 7777 qc flow_insert "1000 3000 1200 4"
              sleep 5
              echo "######################### Read stats for Flows on $n and $m ############################"
              RAWSTATSA=`clickctrl.sh read $n 7777 qc flow_stats`
              RAWSTATSB=`clickctrl.sh read $m 7777 qc flow_stats`
	      echo $RAWSTATSA
	      echo $RAWSTATSB
	      STATSA=`echo $RAWSTATSA | grep "Rate" | awk '{print $4}'`
	      STATSB=`echo $RAWSTATSB | grep "Rate" | awk '{print $4}'`
              echo "$n $m $STATSA $STATSB" >> $FINALRESULTDIR/ig.stats
         clickctrl.sh read $n 7777 cnt count
         clickctrl.sh read $n 7777 cnt byte_count
         clickctrl.sh write $n 7777 cnt reset "1"
         clickctrl.sh read $m 7777 cnt count
         clickctrl.sh read $m 7777 cnt byte_count
         clickctrl.sh write $m 7777 cnt reset "1"
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

