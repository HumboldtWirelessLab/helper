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
  POS=`MAXTRY=$MAXGPSTRY GPSTIME=yes $DIR/../../../../host/bin/gps.sh getgpspos`
  echo "$POS"
  GPSPOS=`echo $POS | awk '{print $1" "$2" "$3}'`
  if [ "x$GPSPOS" != "x0.0 0.0 0.0 0.0" ]; then
    SPEED=`echo $POS | awk '{print $4}'`
    echo "localhost"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.2 7777 gps gps_coord "$GPSPOS"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.2 7777 gps speed "$SPEED"
    echo "sk110"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.110 7777 gps gps_coord "$GPSPOS"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.110 7777 gps speed "$SPEED"
    echo "sk111"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.111 7777 gps gps_coord "$GPSPOS"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.111 7777 gps speed "$SPEED"
    echo "sk112"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.112 7777 gps gps_coord "$GPSPOS"
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write 192.168.3.112 7777 gps speed "$SPEED"
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

