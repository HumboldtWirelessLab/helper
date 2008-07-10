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

if [ -e $DIR/$1 ]; then
    echo "Measurement already exits"
    exit 0
fi

mkdir $DIR/$1

rm -f $DIR/info

vi $DIR/info

DATE=`date +%Y:%m:%d" "%H:%M:%S`

echo "" >> $DIR/info

echo "DATE: $DATE" > $DIR/measurement.info

echo "prepare everything"
../../host/bin/prepare_measurement.sh prepare receiver.dis

. $DIR/receiver.dis.real

GPSD=`ps -le | grep gpsd | wc -l | awk '{print $1}'`

if [ $GPSD -eq 0 ]; then
    echo "Warning: no GPS ! exit (y/n)"
    read key
    
    if [ "x$key" = "xy" ]; then
	exit 0
    fi
fi

NODELIST=`cat $NODETABLE | grep -v "^#" | awk '{print $1}' | sort -u`

for n in $NODELIST; do

    if [ $GPSD -ge 1 ]; then
	echo "Get GPS -Data"
    
        echo -n "Get Position for $n"
        read key
	
        ../../host/bin/gps.sh getdata > $n\_gps.info
    fi

    key=0
    
    while [ $key -le 0 ] || [ $key -gt 6 ]; do
	echo -n "LOS ? 1(full) 2(full,small obstacle) 3(full,more obstacle) 4(obstacle,small los) 5(obstacle, nolos) 6 (fat obstacle) (1-6): "
	read key
	NUMINPUT=`echo $key | egrep "^[1-6]$" | wc -l | awk '{print $1}'`
	if [ $NUMINPUT -eq 0 ]; then
	    key=0
	fi
    done
    
    echo "LOS=$key" > $n.info
        
done

if [ "x$RUNMODE" = "x" ]; then
    RUNMODE=ALL
fi

RESULT=`CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME RUNMODE=$RUNMODE $DIR/../../host/bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/$LOGFILE 2>&1`

mv *.dump $DIR/$1/
mv *.log $DIR/$1/
mv *info $DIR/$1/
cp *.click* $DIR/$1/
cp *.real $DIR/$1/

../../host/bin/prepare_measurement.sh cleanup receiver.dis

echo "$RESULT"

exit 0
