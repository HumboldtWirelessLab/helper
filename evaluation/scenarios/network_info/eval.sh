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


#echo "Eval not valid"

#exit 0

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
  #grep "link from" $DATAFILE | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5" "$7}' | grep -v "=" | sort -u > $EVALUATIONSDIR/linksmetric.all
  xsltproc $DIR/linksmetric.xslt $DATAFILE > $EVALUATIONSDIR/linksmetric.all
  cat $EVALUATIONSDIR/linksmetric.all | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/linksmetric.mat
fi

exit 0

###############################################################################
# bcaststats
###############################################################################

echo "Create bcaststats!"

if [ ! -f $EVALUATIONSDIR/bcaststats.csv ]; then
  xsltproc $DIR/bcaststats.xslt $DATAFILE > $EVALUATIONSDIR/bcaststats.csv
fi

###############################################################################
# linkgraph
###############################################################################

echo "Create linkgraph (Threshold: $THRESHOLD)"

if [ ! -f $EVALUATIONSDIR/graph.mat ]; then

  (cd $DIR; matwrapper "try,metric2graph('$EVALUATIONSDIR/linksmetric.mat','$EVALUATIONSDIR/graph.csv',$THRESHOLD),catch,exit(1),end,exit(0)" 1> /dev/null)
  sed "s#,# #g" $EVALUATIONSDIR/graph.csv > $EVALUATIONSDIR/graph.mat
fi

###############################################################################
# networkstats
###############################################################################

echo "Networkstats!"

cat $EVALUATIONSDIR/bcaststats.csv | sed "s#,# #g" | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/bcaststats.mat
BCASTSIZE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $3}' | sort -u`
BCASTRATE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $4}' | sort -u`
BCASTNODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}'`

(cd $DIR; matwrapper "try,bcaststats2graph('$EVALUATIONSDIR/bcaststats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)

for r in $BCASTRATE; do
  for s in $BCASTSIZE; do
    PARAMS="$r""_""$s"
    GRAPHCSVFILE="$EVALUATIONSDIR/graph_psr_$r""_""$s.csv"
    GRAPHFILE="$EVALUATIONSDIR/graph_psr_$r""_""$s.mat"

    if [ -f $GRAPHCSVFILE ]; then
      cat $GRAPHCSVFILE | sed "s#,# #g" > $GRAPHFILE
    fi

    if [ ! -f $GRAPHFILE ]; then
      echo -n "" > $GRAPHFILE
      for n in $BCASTNODES; do
        for m in $BCASTNODES; do
          METRIC=`cat $EVALUATIONSDIR/bcaststats.csv | grep -e "^$n,$m,$s,$r" | awk -F , '{print $9}' | head -n 1`

          if [ "x$METRIC" = "x" ]; then
            METRIC=0
          fi

          echo -n "$METRIC " >> $GRAPHFILE
        done
        echo "" >> $GRAPHFILE
      done
    fi

    (cd $DIR; matwrapper "try,show_network_stats('$GRAPHFILE','$EVALUATIONSDIR/','$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)

  done
done
