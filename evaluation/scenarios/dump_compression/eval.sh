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

#echo $RESULTDIR
#(cd $RESULTDIR;ls *.dump)

for d in `(cd $RESULTDIR;ls *.dump)`; do
    ( cd $RESULTDIR; bzip2 -z -9 $d )
done

exit 0

