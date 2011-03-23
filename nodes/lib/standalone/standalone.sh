#!/bin/sh

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


#MODULSDIR
#WIFICONFIG
# incl. MODOPTIONS
#CLICKFILE
#CLICKLOG

MODULSDIR=$DIR/../modules/i586/2.6.32.25
MODOPTIONS=$DIR/../../etc/madwifi/modoptions.japan

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

case "$1" in
    "driver")
      /etc/rc.d/S42olsr_or_brn stop >> /tmp/seismo_brn.log 2>&1
      /sbin/ifconfig ath1 down >> /tmp/seismo_brn.log 2>&1
      CONFIG=$DIR/../../etc/seismo/monitor.b.channel DEVICE="ath0" $DIR/../../bin/wlandevice.sh delete >> /tmp/seismo_brn.log 2>&1
      sleep 1
      MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../bin/wlanmodules.sh uninstall >> /tmp/seismo_brn.log 2>&1
      sleep 1
      MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../bin/wlanmodules.sh install >> /tmp/seismo_brn.log 2>&1
      sleep 10
      /etc/rc.d/S42olsr_or_brn start >> /tmp/seismo_brn.log 2>&1
            ;;
    "brndev")
      CONFIG=$DIR/../../etc/seismo/monitor.b.channel DEVICE="ath0" $DIR/../../bin/wlandevice.sh delete >> /tmp/seismo_brn.log 2>&1
      CONFIG=$DIR/../../etc/seismo/monitor.b.channel DEVICE="ath0" $DIR/../../bin/wlandevice.sh create >> /tmp/seismo_brn.log 2>&1
      CONFIG=$DIR/../../etc/seismo/monitor.b.channel DEVICE="ath0" $DIR/../../bin/wlandevice.sh config_pre_start >> /tmp/seismo_brn.log 2>&1
      CONFIG=$DIR/../../etc/seismo/monitor.b.channel DEVICE="ath0" $DIR/../../bin/wlandevice.sh start  >> /tmp/seismo_brn.log 2>&1
      CONFIG=$DIR/../../etc/seismo/monitor.b.channel DEVICE="ath0" $DIR/../../bin/wlandevice.sh config_post_start >> /tmp/seismo_brn.log 2>&1
      ;;
    "click_start")
      ARCH=`$DIR/../../bin/system.sh get_arch`
      ($DIR/../../bin/click-align-$ARCH $CLICKFILE 2> /dev/null | $DIR/../../bin/click >> /tmp/seismo_brn.log 2>&1 ) &
      sleep 5
      ;;
    "click_stop")
      killall click > /dev/null 2>&1
      ;;
    "setup")
      RUNMODE=$RUNMODE MODULSDIR=$MODULSDIR MODOPTIONS=$MODOPTIONS CONFIG=$CONFIG DEVICE=$DEVICE $0 delaysetup &
      ;;
    "delaysetup")
       sleep 30
       $0 checker &
       
       if [ "x$RUNMODE" = "xDRIVER"  ]; then
         $0 driver
         sleep 1
       fi
       
       $0 brndev
       sleep 1
       
       ;;
    "checker")
       sleep 60
       DEVICE_EX=`/sbin/ifconfig ath0 2> /dev/null | grep ath0 | wc -l`
       
       if [ $DEVICE_EX -eq 0 ]; then
         reboot
       else
	 ROUTE_EX=`/sbin/route -n | grep "10." | wc -l`
	 
	 if [ $ROUTE_EX -eq 0 ]; then
	   reboot
	 fi
       fi
       ;;
    *)
        echo "unknown options"
        ;;
esac

exit 0

