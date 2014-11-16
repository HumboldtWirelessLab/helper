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

if [ -e $DIR/../../bin/functions.sh ]; then
  . $DIR/../../bin/functions.sh
fi

###############################################################################
# Get datafile
###############################################################################

echo "Get Datafile"

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

###############################################################################
# set evaluation sub dir
###############################################################################
EVALUATIONSDIR="$EVALUATIONSDIR""/network_info"
if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

###############################################################################
# create linkmetric.all
###############################################################################
echo "Create linkmetric matrix"

THRESHOLD=400

if [ ! -f $EVALUATIONSDIR/linksmetric.all ]; then
  xsltproc $DIR/linksmetric.xslt $DATAFILE > $EVALUATIONSDIR/linksmetric.all
  cat $EVALUATIONSDIR/linksmetric.all | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/linksmetric.mat
fi

###############################################################################
# bcaststats
###############################################################################

echo "Create bcaststats!"

if [ ! -f $EVALUATIONSDIR/bcaststats.csv ]; then
  xsltproc $DIR/bcaststats.xslt $DATAFILE > $EVALUATIONSDIR/bcaststats.csv
  cat $EVALUATIONSDIR/bcaststats.csv | sed "s#,# #g" | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/bcaststats.mat
fi
