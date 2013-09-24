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

xsltproc $DIR/boid_gravitation.xslt $DATAFILE | sed "s#,# #g" > $EVALUATIONSDIR/boid_gravitation.dat

COUNTGRAVITATION=`cat $EVALUATIONSDIR/boid_gravitation.dat | wc -l`

if [ $COUNTGRAVITATION -eq 0 ]; then
  exit 0;
fi

line=`cat $EVALUATIONSDIR/boid_gravitation.dat | head -n 1`

read TIME X Y Z MASS <<< $line

#echo "$X $Y"

TRACEFILESIZE=`cat $RESULTDIR/$NAME.nam | wc -l`
NONODES=`cat $RESULTDIR/nodes.mac | wc -l`
let GRAVITATION=NONODES

cat $RESULTDIR/$NAME.nam | head -n $NONODES > $RESULTDIR/$NAME.gravitation.nam
echo "n -t 0 -s $GRAVITATION -S DLABEL -l \"Gravitation\" -L \"\"" >> $RESULTDIR/$NAME.gravitation.nam

let NAMTAIL=TRACEFILESIZE-NONODES

cat $RESULTDIR/$NAME.nam | tail -n $NAMTAIL | head -n $NONODES >> $RESULTDIR/$NAME.gravitation.nam
echo "n -t * -s $GRAVITATION  -x $X -y $Y -Z 0 -z 40  -v circle -c red" >> $RESULTDIR/$NAME.gravitation.nam

let NAMTAIL=NAMTAIL-NONODES
cat $RESULTDIR/$NAME.nam | tail -n $NAMTAIL >> $RESULTDIR/$NAME.gravitation.nam

