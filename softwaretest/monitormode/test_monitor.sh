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

TIME=100

chmod 777 $LOGDIR

SEDARG="s#MODULSDIR#$MODULSDIR#g"
SEDARG2="s#LOGDIR#$LOGDIR#g"
SEDARG3="s#WORKDIR#$DIR#g"
cat $DIR/monitortest.mes | grep -v "#" | grep -e "." | awk '{print  $1" "$2" MODULSDIR "$4" "$5" "$6}' | sed -e $SEDARG -e $SEDARG2 -e $SEDARG3 > $DIR/monitortest.mes.tmp 

RESULT=`CONFIGFILE=$DIR/monitortest.mes.tmp MARKER=$REVISION STATUSFD=5 ID=monitormode TIME=$TIME $DIR/../../host/bin/run_single_measurement.sh 5>&1 1>> $LOGDIR/measurement.log 2>&1`

rm -f $DIR/monitortest.mes.tmp

if [ "$RESULT" = "error" ]; then
	echo "error" 1>&$STATUSFD
else
	PACKETCOUNT=`cat $LOGDIR/receiver.log | grep "^1032" | wc -l`
	echo "Packetcount is $PACKETCOUNT"

	if [ $PACKETCOUNT -gt 0 ]; then
		echo "ok" 1>&$STATUSFD
	else
		echo "failed" 1>&$STATUSFD
	fi
fi

mv $LOGDIR/sender.log $LOGDIR/$REVISION\_sender.log
mv $LOGDIR/receiver.log $LOGDIR/$REVISION\_receiver.log
mv $LOGDIR/measurement.log $LOGDIR/$REVISION\_measurement.log

exit 0

