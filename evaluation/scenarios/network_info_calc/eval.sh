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
# set evaluation sub dir
###############################################################################
EVALUATIONSDIR="$EVALUATIONSDIR""/network_info"

###############################################################################
# linkgraph
###############################################################################
THRESHOLD=400

echo "Create linkgraph (Threshold: $THRESHOLD)"

if [ ! -f $EVALUATIONSDIR/graph.mat ]; then
  (cd $DIR; matwrapper "try,metric2graph('$EVALUATIONSDIR/linksmetric.mat','$EVALUATIONSDIR/graph',$THRESHOLD),catch,exit(1),end,exit(0)" 1> /dev/null)
fi

###############################################################################
# networkstats
###############################################################################

echo "Networkstats!"

if [ -f $EVALUATIONSDIR/bcaststats.mat ]; then
  FILESIZE=`wc -c $EVALUATIONSDIR/bcaststats.mat | awk '{print $1}'`
  if [ $FILESIZE -gt 0 ]; then
    (cd $DIR; matwrapper "try,bcaststats2graph('$EVALUATIONSDIR/bcaststats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
  fi
fi

if [ -f $EVALUATIONSDIR/graph_psr.mat ]; then
  FILESIZE=`wc -c $EVALUATIONSDIR/graph_psr.mat | awk '{print $1}'`
  if [ $FILESIZE -gt 0 ]; then
    (cd $DIR; matwrapper "try,nodedegree('$EVALUATIONSDIR/graph_psr.mat', [25 50 75], '$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
  fi
fi

#echo "Result: $?"