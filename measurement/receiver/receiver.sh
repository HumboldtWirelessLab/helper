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

GPSD=`ps -le | grep gpsd | wc -l | awk '{print $1}'`

if [ $GPSD -ge 1 ]; then
    echo "get gpsdata"
    ../../host/bin/gps.sh getdata > gps.info
fi

vi $DIR/info

echo "prepare everything"
../../host/bin/prepare_measurement.sh prepare receiver.dis

. $DIR/receiver.dis.real

RESULT=`CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME $DIR/../../host/bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/$LOGFILE 2>&1`

mv *.dump $DIR/$1/
mv *.log $DIR/$1/
mv *info $DIR/$1/
cp *.click* $DIR/$1/
cp *.real $DIR/$1/

../../host/bin/prepare_measurement.sh cleanup receiver.dis

echo "$RESULT"

exit 0
