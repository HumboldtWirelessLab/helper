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


get_phy_dev() {
    NUMBER=`echo $1 | cut -b 4`
    echo "wifi$NUMBER"
}


case "$1" in
    "help")
	echo "Use $0 settime"
	exit 0;
	;;
    "settime")
	. ../etc/environment/ntpserver
	RDATE=`which rdate | wc -l | awk '{print $1}'`
	if [ $RDATE -gt 0 ]; then
	    rdate $NTPSERVER > /dev/null 2>&1
	    exit 0
	fi
	NTPDATE=`which ntpdate | wc -l | awk '{print $1}'`
	if [ $NTPDATE -gt 0 ]; then
	    ntpdate $NTPSERVER > /dev/null 2>&1
	    exit 0
	fi
	;;
    *)
	;;
esac

exit 0
