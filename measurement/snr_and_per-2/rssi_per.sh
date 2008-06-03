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
	       
LOGDIR=/home/sombrutz/lab/measurement/
RESULTDIR=/home/sombrutz/lab/result/
EVALRESULT=/home/sombrutz/lab/evalresult/

rm -rf $LOGDIR
rm -rf $RESULTDIR
mkdir $LOGDIR
chmod 777 $LOGDIR
mkdir $RESULTDIR
mkdir $EVALRESULT

screen -d -m -S onlineeval
sleep 0.2
screen -S onlineeval -X screen -t runeval
sleep 0.2
screen -S onlineeval -p runeval -X stuff "STOPMARKER=/home/sombrutz/lab/stop WAITTIME=60 $DIR/online_evaluation.sh $RESULTDIR $DIR/evalscript.sh $EVALRESULT $DIR/onlinescript.sh measurement_004"
sleep 5
screen -S onlineeval -p runeval -X stuff $'\n'

for rate in 2 12 24 108; do
    for chan in 1 7 13 36 48 60; do

	RUNSIM=1
	
	if [ $chan -ge 36 ]; then
	    if [ $rate -eq 2 ]; then
		RUNSIM=0
	    fi
	fi
	
	if [ $RUNSIM -eq 1 ]; then
	    for senderpower in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do

		cat /home/sombrutz/lab/helper/nodes/etc/wifi/monitor.default | sed -e "s\POWER=15\POWER=$senderpower\g" -e "s\CHANNEL=11\CHANNEL=$chan\g" > $LOGDIR/monitor_sender
		cat /home/sombrutz/lab/helper/nodes/etc/wifi/monitor.default | sed -e "s\CHANNEL=11\CHANNEL=$chan\g" > $LOGDIR/monitor_receiver
		RATE=$rate
		SEDARG="s#24#$RATE#g"
		cat /home/sombrutz/lab/helper/measurement/snr_and_per/sender.click | sed -e $SEDARG > /home/sombrutz/lab/helper/measurement/snr_and_per/sender.tmp.click
	
		RESULT=`CONFIGFILE=$DIR/rssi_per.mes MARKER=22 STATUSFD=5 TIME=140 ID=RSSI_PER /home/sombrutz/lab/helper/host/bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/measurement.log 2>&1`

		mv $LOGDIR/monitor_sender $LOGDIR/$senderpower\_monitor_sender
		mv $LOGDIR/monitor_receiver $LOGDIR/$senderpower\_monitor_receiver
		mv $LOGDIR/measurement.log $LOGDIR/$senderpower\_measurement.log
		mv $LOGDIR/receiver.log $LOGDIR/$senderpower\_receiver.log
		mv $LOGDIR/sender.log $LOGDIR/$senderpower\_sender.log
	    
	    done
	
    	    mkdir $RESULTDIR/CHANNEL_$chan\_RATE_$rate
    
    	    mv $LOGDIR/* $RESULTDIR/CHANNEL_$chan\_RATE_$rate/
	fi
    done
done

sleep 30
touch /home/sombrutz/lab/stop

sleep 60
screen -S onlineeval -X quit

exit 0
