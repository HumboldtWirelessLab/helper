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

get_arch() {
    $DIR/../../bin/system.sh get_arch
}

case "$1" in
    "responsible")
	    DEV_PREFIX=`echo $DEVICE | cut -b 1-3`
	    if [ "x$DEV_PREFIX" = "xobd" ]; then
	      exit 0
	    else
	      exit 1
	    fi
	    ;;
    "create")
	;;
    "delete")
	killall obd-$NODEARCH
	;;
    "config_pre_start")
	;;
    "start")
	NODEARCH=`$DIR/../../bin/system.sh get_arch`
	killall obd-$NODEARCH
	
	export PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin
	ARCH=$NODEARCH $DIR/../openbeacon/obd-$NODEARCH < /dev/null > /dev/null 2>&1 &
	;;
    "config_post_start")
	;;
    "getiwconfig")
	export PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin
	ps
        ;;
        *)
        ;;
esac

exit 0
