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

EVALUATIONSDIR="$EVALUATIONSDIR""/basic"

if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

if [ -e $DIR/../../bin/functions.sh ]; then
  . $DIR/../../bin/functions.sh
fi

if [ -e $NODEPLACEMENTFILE ]; then
  awk '{ print $1","$2","$3","$4 }' $NODEPLACEMENTFILE | NAME2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/placement.csv
  awk '{print $1" "$2" "$3" "$4 }' $NODEPLACEMENTFILE | NAME2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/placement.mat
fi
