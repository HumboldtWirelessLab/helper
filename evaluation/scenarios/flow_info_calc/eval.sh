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

if [ -f $RESULTDIR/measurement.xml ]; then
  DATAFILE=$RESULTDIR/measurement.xml
else
  if [ -f $EVALUATIONSDIR/measurement.xml ]; then
    DATAFILE=$EVALUATIONSDIR/measurement.xml
  else
    DATAFILE=$RESULTDIR/measurement.log
  fi
fi

EVALUATIONSDIR="$EVALUATIONSDIR""/flow_info"

#NONODES=`cat $RESULTDIR/nodes.mac | wc -l`
#RXCOUNT=`cat $EVALUATIONSDIR/flowstats_rx.csv | wc -l`
#TXBCASTCOUNT=`cat $EVALUATIONSDIR/flowstats_tx.csv | grep "FF-FF-FF-FF-FF-FF" | wc -l`
#TXUNICASTCOUNT=`cat $EVALUATIONSDIR/flowstats_tx.csv | grep -v "FF-FF-FF-FF-FF-FF" | wc -l`

(cd $DIR; matwrapper.sh "flowstats('$EVALUATIONSDIR/flowstats_rx.mat','$EVALUATIONSDIR/flowtime.mat')")
