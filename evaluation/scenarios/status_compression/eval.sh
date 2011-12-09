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
    ( cd $RESULTDIR; tar cvfj status.bz2 status; rm -rf status )
fi

exit 0

