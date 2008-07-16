#!/bin/bash

TIME=2
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

TIME=100

chmod 777 $LOGDIR

SEDARG="s#MODULSDIR#$MODULSDIR#g"
cat $DIR/drivertest.mes | grep -v "#" | grep -e "." | awk '{print  $1" "$2" MODULSDIR "$4" "$5" "$6}' | sed -e $SEDARG > $DIR/drivertest.mes.tmp 

RESULT=`CONFIGFILE=$DIR/drivertest.mes.tmp MARKER=$REVISION STATUSFD=5 ID=driver TIME=$TIME $DIR/../../measurement/bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/measurement.log 2>&1`

rm -f $DIR/drivertest.mes.tmp
mv $LOGDIR/measurement.log $LOGDIR/$REVISION\_measurement.log

if [ "$RESULT" = "error" ]; then
	echo "error" 1>&$STATUSFD
else
	echo "ok" 1>&$STATUSFD
fi

exit 0
