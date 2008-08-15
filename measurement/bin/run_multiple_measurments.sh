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

if [ "x$1" = "xhelp" ] || [ "x$1" = "x" ]; then
  echo "Skript to run measurements as much as you want. After each measurement you'll be ask whether you want one more."
  echo "Use $0 disfile to start"
  exit 0
fi 

DISFILE=$1
RUNMODE=REBOOT

key=y

while [ "x$key" = "xy" ]; do

      HIGHESTDIR=`ls | sort -un | egrep "^[0-9]*$" | tail -n 1`
      if [ "x$HIGHESTDIR" = "x" ]; then
            HIGHESTDIR=0
      fi

      NEXT=`expr $HIGHESTDIR + 1`
      
      RUNMODE=$RUNMODE $DIR/run_measurement $DISFILE $NEXT
      
      if [ "$RUNMODE" = "REBOOT" ]; then
           RUNMODE=CLICK
      fi

      echo -n "Another Measurement (y/n) ? "
      read key

done

exit 0

