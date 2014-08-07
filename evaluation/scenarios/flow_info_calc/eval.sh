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

EVALUATIONSDIR="$EVALUATIONSDIR""/flow_info"

(cd $DIR; matwrapper.sh "flowstats('$EVALUATIONSDIR/flowstats_rx.mat','$EVALUATIONSDIR/flowtime.mat')")
