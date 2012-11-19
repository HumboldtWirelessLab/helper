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

xsltproc $DIR/flooding.xslt $DATAFILE > $EVALUATIONSDIR/floodingstats.csv
xsltproc $DIR/flood2bcast.xslt $DATAFILE | grep -v ",," > $EVALUATIONSDIR/floodingforwardstats.csv

cat $EVALUATIONSDIR/floodingforwardstats.csv | sed "s#,# #g" | sed $FULLIDSED > $EVALUATIONSDIR/floodingforwardstats.mat

(cd $DIR; matlab -nosplash -nodesktop -r "try,flooding2pdr('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
cat $EVALUATIONSDIR/flood2hop_pdr.csv | sed "s#,# #g" > $EVALUATIONSDIR/flood2hop_pdr.mat
cat $EVALUATIONSDIR/flood2src_pdr.csv | sed "s#,# #g" > $EVALUATIONSDIR/flood2src_pdr.mat
cat $EVALUATIONSDIR/flood2hop_pkt_cnt.csv | sed "s#,# #g" > $EVALUATIONSDIR/flood2hop_pkt_cnt.mat


(cd $DIR; matlab -nosplash -nodesktop -r "try,flooding_reachability('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
cat $EVALUATIONSDIR/flood_reach.csv | sed "s#,# #g" > $EVALUATIONSDIR/flood_reach.mat

for i in `(cd $EVALUATIONSDIR/; ls graph_psr_*)`; do
  PARAMS=`echo $i | sed "s#graph_psr_##g" | sed "s#\.txt##g"`
  (cd $DIR; matlab -nosplash -nodesktop -r "try,flood_vs_linkprobing('$EVALUATIONSDIR/flood2hop_pdr.mat', '$EVALUATIONSDIR/flood2hop_pkt_cnt.mat', '$EVALUATIONSDIR/$i', '$EVALUATIONSDIR/', '$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)
done
