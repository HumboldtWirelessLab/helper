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

EVALUATIONSDIR="$EVALUATIONSDIR""/channelstats"
if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

if [ "x$MODE" = "xsim" ]; then
  #summary. Small info
  xsltproc $DIR/simstats_summary.xslt $DATAFILE | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/simstats_summary.csv
  sed "s#,# #g" $EVALUATIONSDIR/simstats_summary.csv > $EVALUATIONSDIR/simstats_summary.mat

  xsltproc $DIR/simstats.xslt $DATAFILE | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/simstats.csv
  sed "s#,# #g" $EVALUATIONSDIR/simstats.csv > $EVALUATIONSDIR/simstats.mat
fi

xsltproc $DIR/channelstats.xslt $DATAFILE | grep -v ",0.000000,0,0,0,0,0,0,0,0,0,0,0,0" | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/channelstats.csv
sed "s#,# #g" $EVALUATIONSDIR/channelstats.csv > $EVALUATIONSDIR/channelstats.mat

