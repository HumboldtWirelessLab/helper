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

EVALUATIONSDIR="$EVALUATIONSDIR""/flooding_info"
if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

#summary. Small info
xsltproc $DIR/flooding_summary.xslt $DATAFILE > $EVALUATIONSDIR/floodingstats.csv

FLOWSTATS=`xsltproc $DIR/flow_stats.xslt $DATAFILE`
PSIZE=`echo $FLOWSTATS | awk '{print $2}'`
PCOUNT=`echo $FLOWSTATS | awk '{print $1}'`


#Small stats. info about all broadcasts
xsltproc --stringparam packetsize "$PSIZE" --stringparam packetcount "$PCOUNT" $DIR/flooding_small_stats.xslt $DATAFILE | grep -v ",," > $EVALUATIONSDIR/floodingsmallstats.csv

cat $EVALUATIONSDIR/floodingsmallstats.csv | sed "s#,# #g" | sed $FULLIDSED > $EVALUATIONSDIR/floodingsmallstats.mat


#Full Info. info about all packets which are send and received. Can be used to get pdr during flooding
xsltproc --stringparam packetsize "$PSIZE" --stringparam packetcount "$PCOUNT" $DIR/flooding_stats.xslt $DATAFILE | grep -v ",," > $EVALUATIONSDIR/floodingforwardstats.csv

cat $EVALUATIONSDIR/floodingforwardstats.csv | sed "s#,# #g" | sed $FULLIDSED > $EVALUATIONSDIR/floodingforwardstats.mat


