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

GPSD=`ps -le | grep gpsd | wc -l | awk '{print $1}'`

if [ $GPSD -eq 0 ]; then
    echo -n "Warning: no GPS ! Exit (y/n) ? "
    read key
    
    if [ "x$key" = "xy" ]; then
	exit 0
    fi
fi

NODELIST=`cat $DIR/receiver.mes | grep -v "^#" | awk '{print $1}' | sort -u`

for n in $NODELIST; do

echo "NODE: $n"

    if [ $GPSD -ge 1 ]; then
	echo "Get GPS -Data"
    
        echo -n "Get Position for $n ! Press any key !"
        read key
	
        $DIR/../../host/bin/gps.sh getdata > $n\_gps.info
    fi

    key=0
    
    while [ $key -le 0 ] || [ $key -gt 10 ]; do
	echo -n "LOS ? 1(full) 2(full,very small obstacle) 3(full,small obstacles) ..... 8(obstacle,very small los) 9(obstacle, nolos) 10(fat obstacle) (1-10): "
	read key
	NUMINPUT=`echo $key | egrep "^[1-9]$|^10$" | wc -l | awk '{print $1}'`
	if [ $NUMINPUT -eq 0 ]; then
	    key=0
	fi
    done
    
    echo "LOS=$key" > $n.info
        
done

mkdir $DIR/$1

rm -f $DIR/info
vi $DIR/info
echo "" >> $DIR/info

DATE=`date +%Y:%m:%d" "%H:%M:%S`
echo "DATE: $DATE" > $DIR/measurement.info

echo "prepare everything"
$DIR/../bin/prepare_measurement.sh prepare receiver.dis

. $DIR/receiver.dis.real

echo "DISFILE: receiver.dis.real" > $DIR/measurement.info

if [ "x$RUNMODE" = "x" ]; then
    RUNMODE=CLICK
fi

for node in $NODELIST; do
	NODEDEVICELIST=`cat $DIR/receiver.mes.real | egrep "^$node[[:space:]]" | awk '{print $2}'`

	for nodedevice in $NODEDEVICELIST; do
		WIFICONFIG=`cat $DIR/receiver.mes.real | awk '{print $1" "$2" "$4}' | grep "^$node $nodedevice" | awk '{print $3}' | sort -u`
		for wificonfig_ac in $WIFICONFIG; do
			if [ -e $wificonfig_ac ]; then
				cp $wificonfig_ac $DIR/$1/
			fi
			if [ -e $DIR/$wificonfig_ac ]; then
				cp $DIR/$wificonfig_ac $DIR/$1/
			fi
			if [ -e $DIR/../../nodes/etc/wifi/$wificonfig_ac ]; then
				cp $DIR/../../nodes/etc/wifi/$wificonfig_ac $DIR/$1/
			fi
		done
	done
done

RESULT=`CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME RUNMODE=$RUNMODE $DIR/../bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/$LOGFILE 2>&1`

mv *.dump $DIR/$1/
mv *.log $DIR/$1/
mv *info $DIR/$1/
cp *.click* $DIR/$1/
cp *.real $DIR/$1/

$DIR/../bin/prepare_measurement.sh cleanup receiver.dis

echo "$RESULT"

exit 0

