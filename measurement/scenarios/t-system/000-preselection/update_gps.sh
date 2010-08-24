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

while [ true ]; do
  POS=`MAXTRY=$MAXGPSTRY $DIR/../../../../host/bin/gps.sh getgpspos`
  echo "$POS"
  if [ "x$POS" != "x0.0 0.0 0.0" ]; then
    echo "" | $DIR/../../../../host/bin/clickctrl.sh write localhost 7777 gps gps_coord $POS
  fi
done
