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
    "click")
	($DIR/../../bin/click-align $DIR/../../etc/seismo/testbed_long_run.click.seismo 2> /dev/null | $DIR/../../bin/click >> /tmp/seismo_brn.log 2>&1 ) &
	sleep 5
	;;
    "start")
        rm -f /tmp/seismo_brn.log > /dev/null
        echo "Start" > /tmp/seismo_brn.log
	sleep 3;
	$0 stop
	sleep 1
	if [ "x$DRIVERSETUP" = "xyes" ]; then
	  $0 driver
	  sleep 1
	fi
	$0 brndev
	sleep 1
	$0 stop
	sleep 1
	$0 click
	;;
    "stop")
	killall click >> /tmp/seismo_brn.log 2>&1
	;;
    "delaystart")
       DRIVERSETUP=$DRIVERSETUP $0 start &
       ;;
    "failed_check")
       sleep 300
      ;;
    *)
        echo "unknown options"
        ;;
esac

exit 0

