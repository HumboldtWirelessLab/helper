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
	    if [ "x$DEV_PREFIX" = "xodb" ]; then
	      exit 0
	    else
	      exit 1
	    fi
	    ;;
    "create")
	;;
    "delete")
	;;
    "config_pre_start")
	;;
    "start")
	NODEARCH=`$DIR/../../bin/system.sh get_arch`
	killall obd-$NODEARCH
	killall obd
	
	(export PATH=$PATH:/usr/bin:/usr/sbin:/bin:/sbin; cd $DIR/../openbeacon; ./obd-$NODEARCH &)
	;;
    "config_post_start")
	;;
    "getiwconfig")
        ;;
        *)
        ;;
esac

exit 0
