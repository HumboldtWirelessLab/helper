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

. $CONFIGFILE

if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

if [ ! -e $EVALUATIONSDIR/rxtx_info ]; then
  mkdir -p $EVALUATIONSDIR/rxtx_info
fi

if [ -f $RESULTDIR/$NAME.tr ]; then
  DATAFILE=$RESULTDIR/$NAME.tr
else
  if [ -f $EVALUATIONSDIR/$NAME.tr ]; then
    DATAFILE=$EVALUATIONSDIR/$NAME.tr
  fi
fi

cat $DATAFILE | awk '{print $2" "$3" "$1" "$8}' | sed -e "s#---#0#g" -e "s#COL#1#g" -e "s#RET#2#g" -e "s#r#0#g" -e "s#s#1#g" -e "s#D#2#" > $EVALUATIONSDIR/rxtx_info/rxtx_timing.dat

exit 0