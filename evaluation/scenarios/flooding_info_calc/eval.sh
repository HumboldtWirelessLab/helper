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

(cd $DIR; matwrapper.sh "try,flooding2pdr('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)

cat $EVALUATIONSDIR/flooding_lasthop_fwd_pdr.csv | sed "s#,# #g" > $EVALUATIONSDIR/flooding_lasthop_fwd_pdr.mat
cat $EVALUATIONSDIR/flooding_lasthop_fwd_pkt_cnt.csv | sed "s#,# #g" > $EVALUATIONSDIR/flooding_lasthop_fwd_pkt_cnt.mat
cat $EVALUATIONSDIR/flooding_lasthop_tx_pdr.csv | sed "s#,# #g" > $EVALUATIONSDIR/flooding_lasthop_tx_pdr.mat
cat $EVALUATIONSDIR/flooding_lasthop_tx_pkt_cnt.csv | sed "s#,# #g" > $EVALUATIONSDIR/flooding_lasthop_tx_pkt_cnt.mat
cat $EVALUATIONSDIR/flooding_src_pdr.csv | sed "s#,# #g" > $EVALUATIONSDIR/flooding_src_pdr.mat

(cd $DIR; matwrapper.sh "try,flooding_reachability('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
cat $EVALUATIONSDIR/flood_reach.csv | sed "s#,# #g" > $EVALUATIONSDIR/flood_reach.mat

(cd $DIR; matwrapper.sh "try,flooding_forward('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
cat $EVALUATIONSDIR/flooding_forward_probability.csv | sed "s#,# #g" > $EVALUATIONSDIR/flooding_forward_probability.mat

for i in `(cd $EVALUATIONSDIR/../network_info; ls graph_psr_*)`; do
  PARAMS=`echo $i | sed "s#graph_psr_##g" | sed "s#\.txt##g"`
  (cd $DIR; matwrapper.sh "try,flooding_vs_linkprobing('$EVALUATIONSDIR/flooding_lasthop_fwd_pdr.mat', '$EVALUATIONSDIR/flooding_lasthop_fwd_pkt_cnt.mat', '$EVALUATIONSDIR/../network_info/$i', '$EVALUATIONSDIR/', '$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)
  cat $EVALUATIONSDIR/flooding_vs_linkprobing_diff_$PARAMS.csv | sed "s#,# #g" > $EVALUATIONSDIR/flooding_vs_linkprobing_diff_$PARAMS.mat
done

exit 0
