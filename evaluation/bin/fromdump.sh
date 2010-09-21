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

if [ "x$ATH" = "xyes" ]; then
  ATHREP=""
else
  ATHREP="//"
fi

if [ "x$SEQ" = "xyes" ]; then
  SEQREP=""
else
  SEQREP="//"
fi

if [ "x$GPS" = "xyes" ]; then
  GPSREP=""
else
  GPSREP="//"
fi

if [ "x$WIFI" = "x" ]; then
  WIFI=805
fi

cat $DIR/../etc/click/eval_wifi_$WIFI.click | sed "s#DUMP#$1#g" | sed "s#//SEQ#$SEQREP#g" | sed "s#//ATH#$ATHREP#g" | sed "s#//GPS#$GPSREP#g" | click-align 2> /dev/null | click 2>&1
