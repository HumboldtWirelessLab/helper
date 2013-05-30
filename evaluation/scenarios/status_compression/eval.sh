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

if [ -e $RESULTDIR/status ]; then
    ( cd $RESULTDIR; tar cfj status.tar.bz2 status; rm -rf status )
fi

if [ -e $RESULTDIR/$NAME.tr ]; then
    ( cd $RESULTDIR; bzip2 -9 $NAME.tr)
fi

if [ -e $RESULTDIR/$NAME.nam ]; then
    ( cd $RESULTDIR; bzip2 -9 $NAME.nam)
fi

if [ -e $RESULTDIR/measurement.log ]; then
    ( cd $RESULTDIR; bzip2 -9 measurement.log)
fi

exit 0

