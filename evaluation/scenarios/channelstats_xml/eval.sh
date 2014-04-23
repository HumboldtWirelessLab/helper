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

FULLSED=""
FULLIDSED=""
while read line; do
  SRCN=`echo $line | awk '{print $1}'` 
  SRCM=`echo $line | awk '{print $3}'`
  SRCID=`echo $line | awk '{print $4}'`

  FULLSED="$FULLSED -e s#$SRCM#$SRCN#g"
  FULLIDSED="$FULLIDSED -e s#$SRCM#$SRCID#g"
done < $RESULTDIR/nodes.mac

EVALUATIONSDIR="$EVALUATIONSDIR""/channelstats"
if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

#summary. Small info
xsltproc $DIR/simstats_summary.xslt $DATAFILE > $EVALUATIONSDIR/simstats_summary.csv

xsltproc $DIR/simstats.xslt $DATAFILE | sed $FULLIDSED > $EVALUATIONSDIR/simstats.csv
cat $EVALUATIONSDIR/simstats.csv | sed "s#,# #g" > $EVALUATIONSDIR/simstats.mat
