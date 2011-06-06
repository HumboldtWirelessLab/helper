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

GPSDECAP="GPSDecap()"
GPSPRINT="GPSPrint(NOWRAP true)"

if [ "x$GPS" = "xyes" ] || [ "x$GPS" = "xold" ]; then
  GPSREP=""
  if [ "x$GPS" = "xold" ]; then
    GPSDECAP="Strip(12)"
    GPSPRINT="GPSPrint\(NOWRAP true,OLDGPS true\)"
  fi
else
  GPSREP="//"
fi

if [ "x$WIFI" = "xraw" ]; then
  echo "FromDump($1,STOP true) -> Print(\"\",2000) -> Discard" | click-align 2> /dev/null | click 2>&1
  exit 0
fi

if [ "x$WIFI" = "x" ]; then
  WIFI=805
fi

if [ "x$2" = "xprint" ]; then
  cat $DIR/../etc/click/eval_wifi_$WIFI.click | sed "s#DUMP#$1#g" | sed "s#//SEQ#$SEQREP#g" | sed "s#//ATH#$ATHREP#g" | sed "s#//GPS#$GPSREP#g" | sed "s#GPSDecap()#$GPSDECAP#g" | sed "s#GPSPrint(NOWRAP true)#$GPSPRINT#g" > ./eval.click
else
  cat $DIR/../etc/click/eval_wifi_$WIFI.click | sed "s#DUMP#$1#g" | sed "s#//SEQ#$SEQREP#g" | sed "s#//ATH#$ATHREP#g" | sed "s#//GPS#$GPSREP#g" | sed "s#GPSDecap()#$GPSDECAP#g" | sed "s#GPSPrint(NOWRAP true)#$GPSPRINT#g" | click-align 2> /dev/null | click 2>&1
fi