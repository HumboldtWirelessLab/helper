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

DISCRIPTIONFILE=$1

$DIR/prepare_measurement.sh prepare $DISCRIPTIONFILE

. $DISCRIPTIONFILE.real

RESULT=`CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME $DIR/run_single_measurement.sh 5>&1 1>> $LOGDIR/$LOGFILE 2>&1`

$DIR/prepare_measurement.sh cleanup $DISCRIPTIONFILE

echo $RESULT

exit 0
