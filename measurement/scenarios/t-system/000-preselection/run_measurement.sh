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

NOSTEPS=13

if [ -e $DIR/$RUN ]; then
  echo "Measurement no. $RUN already exist. CHoose higher one !!"
  exit 0
fi

TARGETHOST=localhost

NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "killall click" > /dev/null 2>&1

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
    GPSD=1
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
	
        MAXTRY=$MAXGPSTRY $DIR/../../../../host/bin/gps.sh getgpspos > $FINALRESULTDIR/gps.info
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
  
  if [ -f $FINALRESULTDIR/gps.info ]; then
    STARTGPS=`cat $FINALRESULTDIR/gps.info`
  else
    STARTGPS="0.0 0.0 0.0"
  fi
  cat $DIR/receiver.click | sed "s#RESULTDIR#$FINALRESULTDIR#g" | sed "s#RUNTIME#$RUNTIME#g" | sed "s#STARTGPS#$STARTGPS#g" > $FINALRESULTDIR/receiver.click

  STEP=1

  if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
    echo "Local process: prestart ($STEP/$NOSTEPS)"
    STEP=`expr $STEP + 1`
    $DIR/$LOCALPROCESS prestart >> $FINALRESULTDIR/localapp.log
  fi

 # exit 0

  if [ $FIRSTRUN -eq 1 ]; then
    echo "Remove old Modules ($STEP/$NOSTEPS)"
    STEP=`expr $STEP + 1`
    NODELIST=$TARGETHOST MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../../../host/bin/wlanmodules.sh rmmod >> $FINALRESULTDIR/measurement.log 2>&1
    
    echo "Load Modules  ($STEP/$NOSTEPS)"
    STEP=`expr $STEP + 1`
    NODELIST=$TARGETHOST MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../../../host/bin/wlanmodules.sh insmod >> $FINALRESULTDIR/measurement.log 2>&1

    echo "Create Device  ($STEP/$NOSTEPS)"
    STEP=`expr $STEP + 1`

    NODE=$TARGETHOST DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../../../host/bin/wlandevices.sh create >> $FINALRESULTDIR/measurement.log 2>&1
    NODE=$TARGETHOST DEVICES=wlan1 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../../../host/bin/wlandevices.sh create >> $FINALRESULTDIR/measurement.log 2>&1

    echo "Start Device  ($STEP/$NOSTEPS)"
    STEP=`expr $STEP + 1`
    NODE=$TARGETHOST DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../../../host/bin/wlandevices.sh start >> $FINALRESULTDIR/measurement.log 2>&1
    NODE=$TARGETHOST DEVICES=wlan1 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../../../host/bin/wlandevices.sh start >> $FINALRESULTDIR/measurement.log 2>&1
    
    FIRSTRUN=0
  else
    STEP=`expr $STEP + 4`
  fi

  echo "Config device  ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`

  NODE=$TARGETHOST DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../../../host/bin/wlandevices.sh config >> $FINALRESULTDIR/measurement.log 2>&1
  NODE=$TARGETHOST DEVICES=wlan1 CONFIG=$FINALRESULTDIR/wificonfig $DIR/../../../../host/bin/wlandevices.sh config >> $FINALRESULTDIR/measurement.log 2>&1

  echo "Get device info (Control) ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
  NODE=$TARGETHOST DEVICES=ath0 $DIR/../../../../host/bin/wlandevices.sh getiwconfig >> $FINALRESULTDIR/wificonfig.txt 2>&1
  NODE=$TARGETHOST DEVICES=wlan1 $DIR/../../../../host/bin/wlandevices.sh getiwconfig >> $FINALRESULTDIR/wificonfig.txt 2>&1

  echo "Start local process ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
  PATH=$DIR/../../host/bin:$PATH;RUNTIME=$TIME RESULTDIR=$FINALRESULTDIR NODELIST=$TARGETHOST $DIR/$LOCALPROCESS start >> $FINALRESULTDIR/localapp.log 2>&1

  echo "Start click ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
  NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "(cd $FINALRESULTDIR; /home/testbed/click-brn/userlevel/click receiver.click > $FINALRESULTDIR/click.log 2>&1)" &

  #add 5 second extra to make sure that we are not faster than the devices (click,application)
  WAITTIME=`expr $RUNTIME + 5`
  echo "Wait for $WAITTIME sec"
  #Countdown
  echo -n -e "Wait... \033[1G"
  for ((i = $WAITTIME; i > 0; i--)); do echo -n -e "Wait... $i \033[1G" ; sleep 1; done
  echo -n -e "                 \033[1G"
  #Normal wait
  #sleep $WAITTIME

  echo "Kill click ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
  NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "killall click" >> $FINALRESULTDIR/measurement.log 2>&1

  echo "Stop local process ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
  PATH=$DIR/../../host/bin:$PATH;NODELIST=$TARGETHOST $DIR/$LOCALPROCESS stop >> $FINALRESULTDIR/localapp.log 2>&1
  
  echo "Poststop local process ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
  PATH=$DIR/../../host/bin:$PATH;NODELIST=$TARGETHOST $DIR/$LOCALPROCESS poststop >> $FINALRESULTDIR/localapp.log

  echo "Check Measurement ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
  echo "############################# CHECK #################################"
  PATH=$DIR/../../host/bin:$PATH;NODELIST=$TARGETHOST RESULTDIR=$FINALRESULTDIR $DIR/$CHECKPROCESS test >> $FINALRESULTDIR/test.log
  cat $FINALRESULTDIR/test.log
  echo "######################### CHECK END #################################"

  echo -n "Exit (No more mearements) (y/n) ? "
  read key

  if [ "x$key" = "xy" ]; then
    exit 0
  fi

  RUN=`expr $RUN + 1`
  
done

