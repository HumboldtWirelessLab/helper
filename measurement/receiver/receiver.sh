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


RESULT=`CONFIGFILE=$DIR/receiver.mes MARKER=21 STATUSFD=5 TIME=260 ID=RECEIVER $DIR/../../host/bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/measurement.log 2>&1`

exit 0
