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

../../host/bin/prepare_measurement.sh prepare todump.dis

. $DIR/todump.dis.real

RESULT=`CONFIGFILE=$NODETABLE MARKER=$NAME STATUSFD=5 TIME=$TIME ID=$NAME $DIR/../../host/bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/$LOGFILE 2>&1`

echo $RESULT

exit 0
