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

ERRORCOUNT=0

while [ true ]; do
  POS=`MAXTRY=$MAXGPSTRY $DIR/../../../../host/bin/gps.sh getgpspos`
  echo "$POS"
  if [ "x$POS" != "x0.0 0.0 0.0" ]; then
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write localhost 7777 gps gps_coord $POS
    ERRORCOUNT=0
  else
    ERRORCOUNT=`expr $ERRORCOUNT + 1`
    if [ $ERRORCOUNT -gt 2 ]; then
      which aplay > /dev/null
      if [ "x$?" = "x0" ]; then
        aplay $DIR/warning.wav > /dev/null 2>&1
      fi
      ERRORCOUNT=1
    fi
  fi
done
