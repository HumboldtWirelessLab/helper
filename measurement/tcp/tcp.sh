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

NODELIST=`cat $DIR/tcp.mes | grep -v "^#" | awk '{print $1}' | sort -u`

mkdir $DIR/$1

rm -f $DIR/info
vi $DIR/info
echo "" >> $DIR/info

DATE=`date +%Y:%m:%d" "%H:%M:%S`
echo "DATE: $DATE" > $DIR/measurement.info

echo "Prepare the Scripts !"

$DIR/../bin/prepare_measurement.sh prepare tcp.dis

. $DIR/tcp.dis.real

echo "DISFILE: tcp.dis.real" >> $DIR/measurement.info

echo "Copy Configs !"

for node in $NODELIST; do
	NODEDEVICELIST=`cat $DIR/tcp.mes.real | egrep "^$node[[:space:]]" | awk '{print $2}'`

	for nodedevice in $NODEDEVICELIST; do
		WIFICONFIG=`cat $DIR/tcp.mes.real | awk '{print $1" "$2" "$5}' | grep "^$node $nodedevice" | awk '{print $3}' | sort -u`
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

echo "Start measurement !"

RESULT=`CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME RUNMODE=$RUNMODE $DIR/../bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/$LOGFILE 2>&1`

mv *.dump $DIR/$1/
mv *.log $DIR/$1/
mv *info $DIR/$1/
cp *.click* $DIR/$1/
cp *.real $DIR/$1/

$DIR/../bin/prepare_measurement.sh cleanup tcp.dis

echo "$RESULT"

exit 0
