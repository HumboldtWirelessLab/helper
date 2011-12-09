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

if [ "x$WIFI" = "x" ]; then
  WIFI=`$DIR/test_header.sh $1`
  if [ "x$WIFI" = "x806" ]; then
    WIFI=raw
  fi
fi

if [ "x$WIFI" = "xraw" ]; then
  echo "FromDump($1,STOP true) -> Print(\"\",2000,TIMESTAMP true) -> Discard" | click-align 2> /dev/null | click 2>&1
  exit 0
fi

if [ "x$RX" = "x" ]; then
  RX="false"
fi

if [ "x$HT" = "x" ]; then
  HT="false"
fi

if [ "x$EVM" = "x" ]; then
  EVM="false"
fi

if [ "x$CONTENT" = "xyes" ]; then
  WRAP=""
  NOWRAP_PARAM=true
else
  WRAP="//"
  NOWRAP_PARAM=false
fi

if [ "x$2" = "xprint" ]; then
  cat $DIR/../etc/click/eval_wifi_$WIFI.click | sed -e "s#DUMP#$1#g" -e "s#//SEQ#$SEQREP#g" -e "s#//ATH#$ATHREP#g" -e "s#//GPS#$GPSREP#g" -e "s#GPSDecap()#$GPSDECAP#g" -e "s#GPSPrint(NOWRAP true)#$GPSPRINT#g" -e "s#PARAMS_HT#$HT#g" -e "s#PARAMS_RX#$RX#g" -e "s#PARAMS_EVM#$EVM#g" -e "s#//WRAP#$WRAP#g" -e "s#NOWRAP_PARAMS#$NOWRAP_PARAM#g" | click-align 2> /dev/null
else
  cat $DIR/../etc/click/eval_wifi_$WIFI.click | sed -e "s#DUMP#$1#g" -e "s#//SEQ#$SEQREP#g" -e "s#//ATH#$ATHREP#g" -e "s#//GPS#$GPSREP#g" -e "s#GPSDecap()#$GPSDECAP#g" -e "s#GPSPrint(NOWRAP true)#$GPSPRINT#g" -e "s#PARAMS_HT#$HT#g" -e "s#PARAMS_RX#$RX#g" -e "s#PARAMS_EVM#$EVM#g" -e "s#//WRAP#$WRAP#g" -e "s#NOWRAP_PARAMS#$NOWRAP_PARAM#g" | click-align 2> /dev/null | click 2>&1
fi
