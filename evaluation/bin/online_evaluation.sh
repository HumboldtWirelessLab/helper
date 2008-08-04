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

DISFILE=$1

. $DISFILE

while [ ! -e $STOPMARKER ]; do
    DIRS=`( cd $RESULTDIR; find -maxdepth 1 -type d | grep -v "^.$" | sed -e "s#\./##g" )`
    for d in $DIRS; do
	if [ -e $RESULTSIR/$d/measurement_fin ]; then
	fi
    done
done

exit 0
