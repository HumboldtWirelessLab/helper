#!/bin/bash

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

AVAILABLECHANNELS="( 1 2 3 4 5 6 7 8 9 10 11 12 13 36 40 44 48 52 56 60 64 100 104 108 112 116 120 124 128 132 136 140 )"

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

. $DIR/config

if [ "x$1" = "x" ]; then
  echo "use $0 NO_OF_FIRSTRUN"
  echo "e.g. $0 1"
  exit 0
fi

RUN=$1

if [ -e $DIR/$RUN ]; then
  echo "Measurement no. $RUN already exist. CHoose higher one !!"
  exit 0
fi

killall click

WANTEXIT=0

if [ "x$FIRSTRUN" = "x" ]; then
  FIRSTRUN=1
fi

while [ $WANTEXIT -eq 0 ]; do

  FINALRESULTDIR=$DIR/$RUN
  
  mkdir $FINALRESULTDIR
  chmod 777 $FINALRESULTDIR

  if [ "x$GPS" = "xyes" ]; then
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

  if [ "$WANTGPS" = "yes" ]; then  

    if [ $GPSD -ge 1 ]; then
        echo "Get GPS -Data"
    
        echo -n "Get Position ! Press any key !"
        read key
	
        $DIR/../../../../host/bin/gps.sh getgpspos > $FINALRESULTDIR/gps.info
    fi
  fi

  if [ "x$NOTICE" = "xyes" ]; then
    rm -f $FINALRESULTDIR/info
    vi $FINALRESULTDIR/info
    echo "" >> $FINALRESULTDIR/info
  fi

  DATE=`date +%Y:%m:%d" "%H:%M:%S`
  echo "DATE: $DATE" > $FINALRESULTDIR/measurement.info

  echo "Prepare the Scripts !"

  if [ "x$CHANNEL" = "xselect" ]; then
    FINALCHANNEL=0
    VALIDCHANNEL=0
    while [ $VALIDCHANNEL -eq 0 ]; do
      echo -n "Choose one of the channels $AVAILABLECHANNELS: "
      read key
      VALIDCHANNEL=`echo $AVAILABLECHANNELS | grep " $key " | wc -l`
    done
    FINALCHANNEL=$key
  else
    FINALCHANNEL=$CHANNEL
  fi

  cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$FINALCHANNEL#g" > $FINALRESULTDIR/wificonfig

  cat $DIR/receiver.click | sed "s#RESULTDIR#$FINALRESULTDIR#g" | sed "s#RUNTIME#$RUNTIME#g" > $FINALRESULTDIR/receiver.click

  if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
    echo "Local process: prestart"
    $DIR/$LOCALPROCESS prestart >> $FINALRESULTDIR/localapp.log
  fi

 # exit 0

  if [ $FIRSTRUN -eq 1 ]; then
    NODELIST=localhost MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../host/bin/wlanmodules.sh insmod >> $FINALRESULTDIR/measurement.log
    NODE=localhost DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../host/bin/wlandevices.sh create >> $FINALRESULTDIR/measurement.log

    NODE=localhost DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../host/bin/wlandevices.sh start >> $FINALRESULTDIR/measurement.log
    
    FIRSTRUN=0
  fi

  NODE=localhost DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../host/bin/wlandevices.sh config >> $FINALRESULTDIR/measurement.log

  NODE=localhost DEVICES=ath0 $DIR/../../host/bin/wlandevices.sh getiwconfig >> $FINALRESULTDIR/wificonfig.txt

  PATH=$DIR/../../host/bin:$PATH;RUNTIME=$TIME RESULTDIR=$FINALRESULTDIR NODELIST=localhost $DIR/$LOCALPROCESS start >> $FINALRESULTDIR/localapp.log 2>&1

  #(cd $FINALRESULTDIR; click receiver.click > $FINALRESULTDIR/click.log 2>&1)

  PATH=$DIR/../../host/bin:$PATH;NODELIST=localhost $DIR/$LOCALPROCESS stop >> $FINALRESULTDIR/localapp.log 2>&1
  PATH=$DIR/../../host/bin:$PATH;NODELIST=localhost $DIR/$LOCALPROCESS poststop >> $FINALRESULTDIR/localapp.log

  echo -n "Exit (No more mearements) (y/n) ? "
  read key
    
  if [ "x$key" = "xy" ]; then
    exit 0
  fi
  
  RUN=`expr $RUN + 1`
  
done
