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


trap abort_measurement 1 2 3 6

abort_measurement() {
  NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "killall click" > /dev/null 2>&1
  exit 0
}


RUN=$1

NOSTEPS=13

if [ -e $DIR/$RUN ]; then
  echo "Measurement no. $RUN already exist. CHoose higher one !!"
  exit 0
fi

TARGETHOST=localhost


echo "Kill old click"
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "killall click" > /dev/null 2>&1

echo "Unload old modules"
NODELIST=$TARGETHOST MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../../../host/bin/wlanmodules.sh rmmod > /dev/null 2>&1
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "rmmod ar9170usb" > /dev/null 2>&1

echo "Load new Modules"
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "modprobe ath5k" > /dev/null 2>&1
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "modprobe ath9k" > /dev/null 2>&1
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "modprobe ar9170usb" > /dev/null 2>&1

echo "Restart gpsd"
NODELIST=$TARGETHOST $DIR/../../../../host/bin/run_on_nodes.sh "/etc/init.d/gpsd restart" > /dev/null 2>&1

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

  cp $DIR/config $FINALRESULTDIR/

  DATE=`date +%Y:%m:%d" "%H:%M:%S`
  echo "DATE: $DATE" > $FINALRESULTDIR/measurement.info

  echo "Prepare the Scripts !"

  FOUNDDEVICES=""

  SEDARG=""

  EXATH0=`iwconfig 2>&1 | grep wifi0 | awk '{print $1}' 2>/dev/null`
  if [ "x$EXATH0" != "xwifi0" ]; then
    EXATH0=`iwconfig 2>&1 | grep wlan0 | awk '{print $1}' 2>/dev/null`
    if [ "x$EXATH0" = "xwlan0" ]; then
      EXATH0="1"
      echo "Found intern WIFI"
      SEDARG="$SEDARG -e s#//ath0##g"
      FOUNDDEVICES="$FOUNDDEVICES ath0"
    else
      EXATH0="0"
    fi
  else
    EXATH0="1"
    echo "Found intern WIFI"
    SEDARG="$SEDARG -e s#//ath0##g"
    FOUNDDEVICES="$FOUNDDEVICES ath0"
  fi

  EXATH1=`iwconfig 2>&1 | grep wifi1 | awk '{print $1}' 2>/dev/null`
  if [ "x$EXATH1" != "xwifi1" ]; then
    EXATH1=`iwconfig 2>&1 | grep wlan1 | awk '{print $1}' 2>/dev/null`
    if [ "x$EXATH1" = "xwlan1" ]; then
      EXATH1="1"
      echo "Found pcmcia WIFI"
      SEDARG="$SEDARG -e s#//ath1##g"
      FOUNDDEVICES="$FOUNDDEVICES ath1"
    else
      EXATH1="0"
    fi
  else
    EXATH1="1"
    echo "Found pcmcia WIFI"
    SEDARG="$SEDARG -e s#//ath1##g"
    FOUNDDEVICES="$FOUNDDEVICES ath1"
  fi

  EXWLAN2=`iwconfig 2>&1 | grep wlan2 | awk '{print $1}' 2>/dev/null`
  if [ "x$EXWLAN2" = "xwlan2" ]; then
    EXWLAN2="1"
    echo "Found USB1 WIFI"
    SEDARG="$SEDARG -e s#//wlan2##g"
    FOUNDDEVICES="$FOUNDDEVICES wlan2"
  else
    EXWLAN2="0"
  fi

  EXWLAN3=`iwconfig 2>&1 | grep wlan3 | awk '{print $1}' 2> /dev/null`
  if [ "x$EXWLAN3" = "xwlan3" ]; then
    EXWLAN3="1"
    echo "Found USB2 WIFI"
    SEDARG="$SEDARG -e s#//wlan3##g"
    FOUNDDEVICES="$FOUNDDEVICES wlan3"
  else
    EXWLAN3="0"
  fi

  if [ "x$CHANNEL" = "xselect" ]; then
    for d in ath0 ath1 wlan2 wlan3; do
      DEVEX=`echo $FOUNDDEVICES | grep $d | wc -l`

      if [ "x$DEVEX" = "x1" ]; then
        FINALCHANNEL=0
        VALIDCHANNEL=0
        while [ $VALIDCHANNEL -eq 0 ]; do
          echo -n "DEVICE $d: Choose one of the channels $AVAILABLECHANNELS: "
          read key
          VALIDCHANNEL=`echo $AVAILABLECHANNELS | grep " $key " | wc -l`
        done
        FINALCHANNEL=$key
      else
        FINALCHANNEL=1
      fi
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$FINALCHANNEL#g" > $FINALRESULTDIR/wificonfig_$d
    done
  else
    FINALCHANNEL=$CHANNEL
    if [ "x$INTERN_CHANNEL" != "x" ]; then
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$INTERN_CHANNEL#g" > $FINALRESULTDIR/wificonfig_ath0
    else
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$FINALCHANNEL#g" > $FINALRESULTDIR/wificonfig_ath0
    fi
    if [ "x$PCMCIA_CHANNEL" != "x" ]; then
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$PCMCIA_CHANNEL#g" > $FINALRESULTDIR/wificonfig_ath1
    else
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$FINALCHANNEL#g" > $FINALRESULTDIR/wificonfig_ath1
    fi
    if [ "x$USB1_CHANNEL" != "x" ]; then
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$USB1_CHANNEL#g" > $FINALRESULTDIR/wificonfig_wlan2
    else
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$FINALCHANNEL#g" > $FINALRESULTDIR/wificonfig_wlan2
    fi
    if [ "x$USB2_CHANNEL" != "x" ]; then
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$USB2_CHANNEL#g" > $FINALRESULTDIR/wificonfig_wlan3
    else
      cat $DIR/wificonfig | sed "s#PARAMSCHANNEL#$FINALCHANNEL#g" > $FINALRESULTDIR/wificonfig_wlan3
    fi
  fi

  if [ -f $FINALRESULTDIR/gps.info ]; then
    STARTGPS=`cat $FINALRESULTDIR/gps.info`
  else
    STARTGPS="0.0 0.0 0.0"
  fi
  cat $DIR/receiver.click | sed $SEDARG | sed "s#PROBETIME#$PROBETIME#g" | sed "s#RESULTDIR#$FINALRESULTDIR#g" | sed "s#RUNTIME#$RUNTIME#g" | sed "s#STARTGPS#$STARTGPS#g" > $FINALRESULTDIR/receiver.click

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

    NODE=$TARGETHOST DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig_ath0 $DIR/../../../../host/bin/wlandevices.sh create >> $FINALRESULTDIR/measurement.log 2>&1
    if [ "x$EXATH1" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=ath1 CONFIG=$FINALRESULTDIR/wificonfig_ath1 $DIR/../../../../host/bin/wlandevices.sh create >> $FINALRESULTDIR/measurement.log 2>&1
    fi
    if [ "x$EXWLAN2" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan2 CONFIG=$FINALRESULTDIR/wificonfig_wlan2 $DIR/../../../../host/bin/wlandevices.sh create >> $FINALRESULTDIR/measurement.log 2>&1
    fi
    if [ "x$EXWLAN3" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan3 CONFIG=$FINALRESULTDIR/wificonfig_wlan3 $DIR/../../../../host/bin/wlandevices.sh create >> $FINALRESULTDIR/measurement.log 2>&1
    fi

    echo "Start Device  ($STEP/$NOSTEPS)"
    STEP=`expr $STEP + 1`
    NODE=$TARGETHOST DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig_ath0 $DIR/../../../../host/bin/wlandevices.sh start >> $FINALRESULTDIR/measurement.log 2>&1
    if [ "x$EXATH1" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=ath1 CONFIG=$FINALRESULTDIR/wificonfig_ath1 $DIR/../../../../host/bin/wlandevices.sh start >> $FINALRESULTDIR/measurement.log 2>&1
    fi
    if [ "x$EXWLAN2" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan2 CONFIG=$FINALRESULTDIR/wificonfig_wlan2 $DIR/../../../../host/bin/wlandevices.sh start >> $FINALRESULTDIR/measurement.log 2>&1
    fi
    if [ "x$EXWLAN3" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan3 CONFIG=$FINALRESULTDIR/wificonfig_wlan3 $DIR/../../../../host/bin/wlandevices.sh start >> $FINALRESULTDIR/measurement.log 2>&1
    fi
    FIRSTRUN=0
  else
    STEP=`expr $STEP + 4`
  fi

  echo "Config device  ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`

    NODE=$TARGETHOST DEVICES=ath0 CONFIG=$FINALRESULTDIR/wificonfig_ath0 $DIR/../../../../host/bin/wlandevices.sh config >> $FINALRESULTDIR/measurement.log 2>&1
    if [ "x$EXATH1" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=ath1 CONFIG=$FINALRESULTDIR/wificonfig_ath1 $DIR/../../../../host/bin/wlandevices.sh config >> $FINALRESULTDIR/measurement.log 2>&1
    fi
    if [ "x$EXWLAN2" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan2 CONFIG=$FINALRESULTDIR/wificonfig_wlan2 $DIR/../../../../host/bin/wlandevices.sh config >> $FINALRESULTDIR/measurement.log 2>&1
    fi
    if [ "x$EXWLAN3" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan3 CONFIG=$FINALRESULTDIR/wificonfig_wlan3 $DIR/../../../../host/bin/wlandevices.sh config >> $FINALRESULTDIR/measurement.log 2>&1
    fi
  echo "Get device info (Control) ($STEP/$NOSTEPS)"
  STEP=`expr $STEP + 1`
    NODE=$TARGETHOST DEVICES=ath0 $DIR/../../../../host/bin/wlandevices.sh getiwconfig >> $FINALRESULTDIR/wificonfig.txt 2>&1
    if [ "x$EXATH1" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=ath1 $DIR/../../../../host/bin/wlandevices.sh getiwconfig >> $FINALRESULTDIR/wificonfig.txt 2>&1
    fi
    if [ "x$EXWLAN2" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan2 $DIR/../../../../host/bin/wlandevices.sh getiwconfig >> $FINALRESULTDIR/wificonfig.txt 2>&1
    fi
    if [ "x$EXWLAN3" = "x1" ]; then
      NODE=$TARGETHOST DEVICES=wlan3 $DIR/../../../../host/bin/wlandevices.sh getiwconfig >> $FINALRESULTDIR/wificonfig.txt 2>&1
    fi
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
  for ((i = $WAITTIME; i > 0; i--)); do
    WAITSTR="Wait... $i Status:"
    
    SIZESTR=""
    if [ "x$EXATH0" = "x1" ]; then
        if [ -f $FINALRESULTDIR/devel.ath0.dump ]; then
	  S=`ls -lah $FINALRESULTDIR/devel.ath0.dump | awk '{print $5}'`
	  SIZESTR="$SIZESTR ATH0: $S"
	else
	  SIZESTR="$SIZESTR ATH0: 0"
	fi
    fi
    if [ "x$EXATH1" = "x1" ]; then
        if [ -f $FINALRESULTDIR/devel.ath1.dump ]; then
	  S=`ls -lah $FINALRESULTDIR/devel.ath1.dump | awk '{print $5}'`
	  SIZESTR="$SIZESTR ATH1: $S"
	else
	  SIZESTR="$SIZESTR ATH1: 0"
	fi
    fi
    if [ "x$EXWLAN2" = "x1" ]; then
        if [ -f $FINALRESULTDIR/devel.wlan2.dump ]; then
	  S=`ls -lah $FINALRESULTDIR/devel.wlan2.dump | awk '{print $5}'`
	  SIZESTR="$SIZESTR WLAN2: $S"
	else
	  SIZESTR="$SIZESTR WLAN2: 0"
	fi
    fi
    if [ "x$EXWLAN3" = "x1" ]; then
        if [ -f $FINALRESULTDIR/devel.wlan3.dump ]; then
	  S=`ls -lah $FINALRESULTDIR/devel.wlan3.dump | awk '{print $5}'`
	  SIZESTR="$SIZESTR WLAN3: $S"
	else
	  SIZESTR="$SIZESTR WLAN3: 0"
	fi
    fi
    
    if [ -f $FINALRESULTDIR/localapp.log ]; then
      GPSSTR=`cat $FINALRESULTDIR/localapp.log | tail -n 1`
    else
      GPSSTR="0.0 0.0 0.0"
    fi
    
    echo -n -e "$WAITSTR$SIZESTR GPS: $GPSSTR               \033[1G" ;

    sleep 1; 
  done
  echo -n -e "                                                                                             \033[1G"
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

