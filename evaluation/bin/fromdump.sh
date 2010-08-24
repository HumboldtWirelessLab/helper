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

if [ "x$GPS" = "xyes" ]; then
  cat $DIR/../etc/click/eval_wifi_805_gps.click | sed "s#DUMP#$1#g" | click 2>&1
else
  cat $DIR/../etc/click/eval_wifi_805.click | sed "s#DUMP#$1#g" | click 2>&1
fi