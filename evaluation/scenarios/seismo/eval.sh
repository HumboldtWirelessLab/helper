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
FULLIDSED="-e s#FF-FF-FF-FF-FF-FF#255#g -e s#FF-FF-FF-FF-FF-FE#254#g -e s#00-00-00-00-00-00#0#g"
while read line; do
  SRCN=`echo $line | awk '{print $1}'` 
  SRCM=`echo $line | awk '{print $3}'`
  SRCID=`echo $line | awk '{print $4}'`

  FULLSED="$FULLSED -e s#$SRCM#$SRCN#g"
  FULLIDSED="$FULLIDSED -e s#$SRCM#$SRCID#g"
done < $RESULTDIR/nodes.mac

EVALUATIONSDIR="$EVALUATIONSDIR""/seismo"
if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

xsltproc $DIR/seismo_cooperative.xslt $DATAFILE > $EVALUATIONSDIR/seismo_cooperative.csv
xsltproc $DIR/seismo_lta_sta.xslt $DATAFILE > $EVALUATIONSDIR/seismo_lta_sta.csv

cat $EVALUATIONSDIR/seismo_cooperative.csv | sed $FULLIDSED | sed "s#,# #g" > $EVALUATIONSDIR/seismo_cooperative.mat
cat $EVALUATIONSDIR/seismo_lta_sta.csv | sed $FULLIDSED | sed "s#,# #g" > $EVALUATIONSDIR/seismo_lta_sta.mat

