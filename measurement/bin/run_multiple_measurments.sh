#!/bin/bash

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
  echo "Use $0 DESFILE to start. Options (ENVIRONMENTVARS):"
  echo "FIRSTRUNMODE (REBOOT|CLICK): What should be done before the first measuremnt (TESTBED)"
  echo 
  exit 0
fi 

DESFILE=$1

. $DESFILE

if [ "x$FIRSTRUNMODE" = "x" ]; then
  RUNMODE=REBOOT
else
  RUNMODE=$FIRSTRUNMODE
fi

if [ "x$MULTIRUNMODE" = "x" ]; then
  MULTIRUNMODE="CLICK"
fi

if [ "x$MULTIREPEAT" = "x" ]; then
  MULTIREPEAT="1"
fi

if [ "x$MULTIWAIT" = "x" ]; then
  MULTIWAIT="0"
fi

if [ "x$SIMULATION" = "x" ]; then
  COMMAND=`echo $0 | sed "s#$DIR##g" | sed "s#/##g"`
  if [ "$COMMAND" = "run_multiple_sims.sh" ]; then
    SIMULATION="1"
  else
    SIMULATION="0"
  fi
fi


RUNNUMBER=0
key=y

#echo "RUNS $RUNS"
#echo "$PWD"
#echo "$DESFILE"

while [ "x$key" = "xy" ]; do
      RUNNUMBER=`expr $RUNNUMBER + 1`

      if [ "x$MULTIWAIT" = "x1" ]; then
        echo -n "Press Key to run $RUNNUMBER. measurement"
        read -n 1 trash
      fi

      HIGHESTDIR=`ls | sort -un | egrep "^[0-9]*$" | tail -n 1`
      if [ "x$HIGHESTDIR" = "x" ]; then
            HIGHESTDIR=0
      fi

      NEXT=`expr $HIGHESTDIR + 1`

      if [ $SIMULATION -eq 0 ]; then
        TESTONLY=$TESTONLY RUNMODE=$RUNMODE $DIR/run_measurement.sh $DESFILE $NEXT
        RUNMODE=$MULTIRUNMODE
      else
        PREPARE_ONLY=$PREPARE_ONLY $DIR/../../simulation/bin/run_sim.sh ns $DESFILE $NEXT
      fi

      if [ "$MULTIREPEAT" = "ASK" ]; then
        echo -n "Another Measurement (y/n) ? "
        read key
      else
        if [ $RUNNUMBER -eq $MULTIREPEAT ]; then
          key=n
        fi
      fi

done

exit 0

