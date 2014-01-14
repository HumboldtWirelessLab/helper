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
if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi


xsltproc $DIR/flowstats_rx.xslt $DATAFILE | grep -v ",," > $EVALUATIONSDIR/flowstats_rx.csv
xsltproc $DIR/flowstats_tx.xslt $DATAFILE | grep -v ",," > $EVALUATIONSDIR/flowstats_tx.csv

NONODES=`cat $RESULTDIR/nodes.mac | wc -l`
RXCOUNT=`cat $EVALUATIONSDIR/flowstats_rx.csv | wc -l`
TXBCASTCOUNT=`cat $EVALUATIONSDIR/flowstats_tx.csv | grep "FF-FF-FF-FF-FF-FF" | wc -l`
TXUNICASTCOUNT=`cat $EVALUATIONSDIR/flowstats_tx.csv | grep -v "FF-FF-FF-FF-FF-FF" | wc -l`

cat $EVALUATIONSDIR/flowstats_rx.csv | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac | sed "s#,# #g" > $EVALUATIONSDIR/flowstats_rx.mat
cat $EVALUATIONSDIR/flowstats_tx.csv | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac | sed "s#,# #g" > $EVALUATIONSDIR/flowstats_tx.mat
