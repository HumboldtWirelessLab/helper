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

. $DIR/functions.sh


case "$1" in
	"help")
		echo "Use $0 getdata "
		;;
	"getdata")
		gpspipe -t -r -n 40	
		;;
	"help")
		echo "Take a look at http://www.kowoma.de/gps/zusatzerklaerungen/NMEA.htm"
		;;
	*)
		$0 help
		;;
esac

exit 0		
