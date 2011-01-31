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
    "save_info")
	    DEV_PREFIX=`echo $DEVICE | cut -b 1-4`
	    if [ "x$DEV_PREFIX" = "xwlan" ]; then
	      exit 0
	    else
	      exit 1
	    fi
	    ;;
    "restore")
	    ;;
        *)
            ;;
esac

exit 0
