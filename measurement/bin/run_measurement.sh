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

if [ -e $pwd/$2 ]; then
    echo "Measurement already exits"
    exit 0
fi

DISCRIPTIONFILE=$1
.  $DISCRIPTIONFILE

NODELIST=`cat $pwd/$NODETABLE | grep -v "^#" | awk '{print $1}' | sort -u`

if [ "x$GPS" = "xyes" ] || [ "x$GPS" = "xsingle" ] || [ "x$LOS" = "xyes" ]; then
  if [ "x$GPS" = "xyes" ] || [ "x$GPS" = "xsingle" ]; then
    WANTGPS="yes"
    FIRSTNODE=""

    GPSD=`ps -le | grep gpsd | wc -l | awk '{print $1}'`
    if [ $GPSD -eq 0 ]; then
      echo -n "Warning: no GPS ! Exit (y/n) ? "
      read key
    
      if [ "x$key" = "xy" ]; then
        exit 0
      fi
    fi
  else
    WANTGPS="no"
  fi


  for n in $NODELIST; do
    echo "NODE: $n"

    if [ "$WANTGPS" = "yes" ]; then  
      if [ "x$FIRSTNODE" = "x" ]; then
          FIRSTNODE=$n
      fi

      if [ $GPSD -ge 1 ]; then
        if [ "$GPS" = "single" ] && [ "x$nx" != "x$FIRSTNODEx"; then
          cat $pwd/$FIRSTNODE\_gps.info > $pwd/$n\_gps.info
        else
          echo "Get GPS -Data"
    
          echo -n "Get Position for $n ! Press any key !"
          read key
	
          $DIR/../../host/bin/gps.sh getdata > $pwd/$n\_gps.info
        fi
      fi
    fi

    if [ "x$LOS" = "xyes" ]; then
      key=0
    
      while [ $key -le 0 ] || [ $key -gt 10 ]; do
	echo -n "LOS ? 1(full) 2(full,very small obstacle) 3(full,small obstacles) ..... 8(obstacle,very small los) 9(obstacle, nolos) 10(fat obstacle) (1-10): "
	read key
	NUMINPUT=`echo $key | egrep "^[1-9]$|^10$" | wc -l | awk '{print $1}'`
	if [ $NUMINPUT -eq 0 ]; then
	    key=0
	fi
      done
    
      echo "LOS=$key" > $pwd/$n.info
    fi  
  done
fi

mkdir $pwd/$2

if [ "x$NOTICE" = "xyes" ]; then
  rm -f $pwd/info
  vi $pwd/info
  echo "" >> $pwd/info
fi

DATE=`date +%Y:%m:%d" "%H:%M:%S`
echo "DATE: $DATE" > $pwd/measurement.info

echo "Prepare the Scripts !"

$DIR/prepare_measurement.sh prepare $DISCRIPTIONFILE

. $DISCRIPTIONFILE.real

echo "DISFILE: $DISCRIPTIONFILE.real" >> $pwd/measurement.info

echo "Copy Configs !"

for node in $NODELIST; do
	NODEDEVICELIST=`cat $pwd/$DISCRIPTIONFILE.real | egrep "^$node[[:space:]]" | awk '{print $2}'`

	for nodedevice in $NODEDEVICELIST; do
		WIFICONFIG=`cat $pwd/$NODETABLE | awk '{print $1" "$2" "$5}' | grep "^$node $nodedevice" | awk '{print $3}' | sort -u`
		for wificonfig_ac in $WIFICONFIG; do
			if [ -e $wificonfig_ac ]; then
				cp $wificonfig_ac $pwd/$2/
			fi
			if [ -e $pwd/$wificonfig_ac ]; then
				cp $pwd/$wificonfig_ac $pwd/$2/
			fi
			if [ -e $DIR/../../nodes/etc/wifi/$wificonfig_ac ]; then
				cp $DIR/../../nodes/etc/wifi/$wificonfig_ac $pwd/$2/
			fi
		done
	done
done

if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
  echo "Start local process"
  $LOCALPROCESS start
fi

echo "Start measurement !"

RESULT=`CLICKMODE=$CLICKMODE CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME RUNMODE=$RUNMODE $DIR/run_single_measurement.sh 5>&1 6>&2 1>> $LOGDIR/$LOGFILE 2>&1`

if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
  echo "Stop local process"
  $LOCALPROCESS stop
fi

mv *.dump $pwd/$2/
mv *.log $pwd/$2/
mv *info $pwd/$2/
cp *.click* $pwd/$2/
cp *.real $pwd/$2/

$DIR/prepare_measurement.sh cleanup $DISCRIPTIONFILE

echo $RESULT

exit 0
