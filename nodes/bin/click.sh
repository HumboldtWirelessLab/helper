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
                                                                    

case "$1" in
    "install")
	MODLIST="proclikefs.ko click.ko"
	
	mkdir /tmp/click
	
	KERNELVERSION=`uname -r`
	NODEARCH=`uname -m`
	
	FINMODULSDIR=`echo $MODULSDIR | sed -e "s#KERNELVERSION#$KERNELVERSION#g" -e "s#NODEARCH#$NODEARCH#g"`
	
	for mod in $MODLIST
	do
	    if [ -f ${FINMODULSDIR}/$mod ]; then
		echo "insmod $mod"
		insmod ${FINMODULSDIR}/$mod
	    fi
	done
	
	mount -t click none /tmp/click
	
	;;
    "uninstall")
	MODLIST="click proclikefs"
    
	umount /tmp/click
	rm -rf /tmp/click
	
	for mod in $MODLIST
	do
	    MOD_EX=`lsmod | grep $mod | wc -l`

	    if [ ! $MOD_EX = 0 ]; then
		echo "rmmod $mod"
		rmmod $mod
	    fi
	done
	;;
    "reinstall")
	MODULSDIR=$MODULSDIR $0 uninstall
	MODULSDIR=$MODULSDIR $0 install
	;;
    "kclick_start")
        ARCH=`uname -m`
        echo $$ > /tmp/kclick_tool.pid
        rm -f $LOGFILE;
        echo -n "" > $LOGFILE
        cat /proc/kmsg >> $LOGFILE &
        echo $! > /tmp/kclick_log.pid
        $DIR/kcontrolsocket.sh &
        echo $! > /tmp/kclick_ctrl.pid
	if [ -f $DIR/sync_gateway-$ARCH ]; then
	  $DIR/sync_gateway-$ARCH &
	  echo $! > /tmp/kclick_syncctrl.pid
        fi
	;;
    "kclick_stop")
        if [ -f /tmp/kclick_log.pid ]; then
          KL_PID=`cat /tmp/kclick_log.pid`
          kill -9 $KL_PID
          rm /tmp/kclick_log.pid
        fi
        if [ -f /tmp/kclick_ctrl.pid ]; then
          KCTRL_PID=`cat /tmp/kclick_ctrl.pid`
          kill -9 $KCTRL_PID
          rm /tmp/kclick_ctrl.pid
        fi
        if [ -f /tmp/kclick_tool.pid ]; then
          KC_PID=`cat /tmp/kclick_tool.pid`
          kill -9 $KC_PID
          rm /tmp/kclick_tool.pid
        fi
        if [ -f /tmp/kclick_syncctrl.pid ]; then
          SC_PID=`cat /tmp/kclick_syncctrl.pid`
          kill -9 $SC_PID
          rm /tmp/kclick_syncctrl.pid
        fi
        ;;
    *)
	echo "unknown options"
	;;
esac

exit 0
