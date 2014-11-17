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

EVALUATIONSDIR="$EVALUATIONSDIR""/flow_info"

if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi


(cd $DIR; matwrapper.sh "try,flowstats('$EVALUATIONSDIR/flowstats_rx.mat','$EVALUATIONSDIR/flowtime'),catch,exit(1),end,exit(0)")

exit 0
