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
      DIR=$pwd/$dir
      ;;
esac

if [ "x$1" = "x" ]; then
  echo "Use RUNMODE=[REBOOT|CLICK] $0 dis.file [targetdir]"
  exit 0
fi

WORKDIR=$pwd
CONFIGDIR=$(dirname "$1")
SIGN=`echo $CONFIGDIR | cut -b 1`

case "$SIGN" in
  "/")
      ;;
  ".")
      CONFIGDIR=$WORKDIR/$CONFIGDIR
      ;;
   *)
      CONFIGDIR=$WORKDIR/$CONFIGDIR
      ;;
esac

if [ -f $1 ]; then
    DISCRIPTIONFILE=$1
    .  $DISCRIPTIONFILE
else
    echo "$1 : No such file !"
    exit 0;
fi

FINALRESULTDIR=`echo $RESULTDIR | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`

trap abort_measurement 1 2 3 6

abort_measurement() {
	
	echo "Master abort"
		
	exit 0;
}

if [ "x$2" = "x" ]; then
    echo "RESULTDIR is target. no Subdir."
else
    if [ -e $FINALRESULTDIR/$2 ]; then
	echo "Measurement already exits"
	exit 0
    else
	FINALRESULTDIR=$FINALRESULTDIR/$2
    fi
fi

mkdir $FINALRESULTDIR
chmod 777 $FINALRESULTDIR

NODELIST=`cat $CONFIGDIR/$NODETABLE | grep -v "^#" | awk '{print $1}' | sort -u`

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
          cat $pwd/$FIRSTNODE\_gps.info > $FINALRESULTDIR/$n\_gps.info
        else
          echo "Get GPS -Data"
    
          echo -n "Get Position for $n ! Press any key !"
          read key
	
          $DIR/../../host/bin/gps.sh getdata > $FINALRESULTDIR/$n\_gps.info
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
    
      echo "LOS=$key" > $FINALRESULTDIR/$n.info
    fi  
  done
fi


if [ "x$NOTICE" = "xyes" ]; then
  rm -f $FINALRESULTDIR/info
  vi $FINALRESULTDIR/info
  echo "" >> $FINALRESULTDIR/info
fi

DATE=`date +%Y:%m:%d" "%H:%M:%S`
echo "DATE: $DATE" > $FINALRESULTDIR/measurement.info

echo "Prepare the Scripts !"

DISCRIPTIONFILENAME=`basename $DISCRIPTIONFILE`
cat $DISCRIPTIONFILE | sed -e "s#WORKDIR#$FINALRESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $FINALRESULTDIR/$DISCRIPTIONFILENAME.tmp

CONFIGDIR=$CONFIGDIR $DIR/prepare_measurement.sh prepare $FINALRESULTDIR/$DISCRIPTIONFILENAME.tmp
mv $FINALRESULTDIR/$DISCRIPTIONFILENAME.tmp.real $FINALRESULTDIR/$DISCRIPTIONFILENAME.real
rm $FINALRESULTDIR/$DISCRIPTIONFILENAME.tmp

. $FINALRESULTDIR/$DISCRIPTIONFILENAME.real

echo "DISFILE: $DISCRIPTIONFILENAME.real" >> $FINALRESULTDIR/measurement.info

echo "Copy Configs !"

for node in $NODELIST; do

	NODEDEVICELIST=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`

	echo $node $NODEDEVICELIST
	for nodedevice in $NODEDEVICELIST; do

		WIFICONFIG=`cat $NODETABLE | awk '{print $1" "$2" "$5}' | egrep "^$node $nodedevice" | awk '{print $3}' | sort -u`

#		echo $node $nodedevice
		for wificonfig_ac in $WIFICONFIG; do

		        if [ -e $wificonfig_ac ]; then
			    cp $wificonfig_ac $FINALRESULTDIR
			else
			    if [ -e $CONFIGDIR/$wificonfig_ac ]; then
				cp $CONFIGDIR/$wificonfig_ac $FINALRESULTDIR
			    else
				if [ -e $DIR/../../nodes/etc/wifi/$wificonfig_ac ]; then
				    cp $DIR/../../nodes/etc/wifi/$wificonfig_ac $FINALRESULTDIR
				fi
			    fi
			fi    

		done
	done
done

echo "Start measurement !"

#TODO: is CLICKMODE used ???

RESULT=`(cd $FINALRESULTDIR; WANTNODELIST=$WANTNODELIST FINALRESULTDIR=$FINALRESULTDIR REMOTEDUMP=$REMOTEDUMP LOCALPROCESS=$LOCALPROCESS CLICKMODE=$CLICKMODE CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME RUNMODE=$RUNMODE $DIR/run_single_measurement.sh 5>&1 6>&2 1>> $LOGDIR/$LOGFILE 2>&1)`

echo $RESULT

if [ $? -eq 0 ]; then
  echo "MODE=testbed CONFIGDIR=$CONFIGDIR CONFIGFILE=$FINALRESULTDIR/$DISCRIPTIONFILENAME.real RESULTDIR=$FINALRESULTDIR $DIR/../../evaluation/bin/start_evaluation.sh"
  MODE=testbed CONFIGDIR=$CONFIGDIR CONFIGFILE=$FINALRESULTDIR/$DISCRIPTIONFILENAME.real RESULTDIR=$FINALRESULTDIR $DIR/../../evaluation/bin/start_evaluation.sh
fi

exit 0
