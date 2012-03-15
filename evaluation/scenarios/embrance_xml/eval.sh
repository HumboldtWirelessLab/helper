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

. $CONFIGFILE

if [ -f $RESULTDIR/measurement.log ]; then
    echo "<$NAME>" > $EVALUATIONSDIR/measurement.xml.tmp
    cat measurement.xml > $EVALUATIONSDIR/measurement.xml.tmp
    cat $RESULTDIR/measurement.log | grep -e "^[[:space:]]*<" > $EVALUATIONSDIR/measurement.xml
    cat $RESULTDIR/measurement.log | grep -v "^[[:space:]]*<" > $EVALUATIONSDIR/measurement_debug.log
fi

exit 0

