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
# create sed arg  for nodenamereplacement
###############################################################################
echo "Create sed arg"

FULLSED=""
FULLMACSED=""
while read line; do
  SRCN=`echo $line | awk '{print $1}'`
  SRCID=`echo $line | awk '{print $4}'`
  SRCMAC=`echo $line | awk '{print $3}'`

  FULLSED="$FULLSED -e s#^$SRCID\$#$SRCN#g"
  FULLMACSED="$FULLMACSED -e s#$SRCMAC#$SRCID#g"
done < $RESULTDIR/nodes.mac

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
  cat $DATAFILE | grep "link from" | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5" "$7}' | grep -v "=" | sort -u > $EVALUATIONSDIR/linksmetric.all
  cat $EVALUATIONSDIR/linksmetric.all | sed $FULLMACSED > $EVALUATIONSDIR/linksmetric.mat
fi

NODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}'`

echo "Create linkgraph (Threshold: $THRESHOLD)"

if [ ! -f $EVALUATIONSDIR/graph.txt ]; then

  (cd $DIR; matwrapper "try,metric2graph('$EVALUATIONSDIR/linksmetric.mat','$EVALUATIONSDIR/graph.csv',$THRESHOLD),catch,exit(1),end,exit(0)" 1> /dev/null)
  cat $EVALUATIONSDIR/graph.csv | sed "s#,# #g" > $EVALUATIONSDIR/graph.txt

fi

###############################################################################
# create partition (etx linktable based)
###############################################################################

echo "Create partitions files"

(cd $DIR; matwrapper "try,partitions('$EVALUATIONSDIR/graph.txt','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi


#echo "Get Bridges and Articulation points"

(cd $DIR; matwrapper "try,get_bridges_and_articulation_points('$EVALUATIONSDIR/graph.txt','$EVALUATIONSDIR/','none'),catch,exit(1),end,exit(0)" 1> /dev/null)


echo "Create clusterfiles and nodedegree!"

if [ ! -f $EVALUATIONSDIR/cluster_0.csv ]; then
  #create cluster file for hole network
  cat $RESULTDIR/nodes.mac | awk '{print $4}' > $EVALUATIONSDIR/cluster_0.csv
fi

( cd $EVALUATIONSDIR; for i in `ls cluster_*.csv`; do N=`echo $i | sed "s#csv#grp#g"`; cat $i | sed $FULLSED > $N; done )

for i in `(cd $EVALUATIONSDIR; ls cluster_*.csv)`; do
  CLUSTERID=`echo $i | sed "s#_# #g" | sed "s#\.# #g" | awk '{print $2}'`
  echo "Cluster: $CLUSTERID"
  (cd $DIR; matwrapper "try,nodedegree('$EVALUATIONSDIR/$i', '$EVALUATIONSDIR/graph.txt', '$EVALUATIONSDIR/', $CLUSTERID ),catch,exit(1),end,exit(0)" 1> /dev/null)
done

###############################################################################
# placement (sim only)
###############################################################################

if [ "x$MODE" = "xsim" ]; then
  cat $NODEPLACEMENTFILE | awk '{print $2" "$3" "$4}' > $EVALUATIONSDIR/nodes.plm
  mkdir $EVALUATIONSDIR/clusterplacement/
fi

###############################################################################
# bcaststats
###############################################################################

echo "Create bcaststats!"

if [ ! -f $EVALUATIONSDIR/bcaststats.csv ]; then
  xsltproc $DIR/bcaststats.xslt $DATAFILE > $EVALUATIONSDIR/bcaststats.csv
fi

###############################################################################
# networkstats
###############################################################################

echo "Networkstats!"

cat $EVALUATIONSDIR/bcaststats.csv | sed "s#,# #g" | sed $FULLMACSED > $EVALUATIONSDIR/bcaststats.mat
BCASTSIZE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $3}' | sort -u`
BCASTRATE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $4}' | sort -u`
BCASTNODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}'`

(cd $DIR; matwrapper "try,bcaststats2graph('$EVALUATIONSDIR/bcaststats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)

for r in $BCASTRATE; do
  for s in $BCASTSIZE; do
    GRAPHCSVFILE="$EVALUATIONSDIR/graph_psr_$r""_""$s.csv"
    GRAPHFILE="$EVALUATIONSDIR/graph_psr_$r""_""$s.txt"

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

    PARAMS="$r""_""$s"
    TARGET="$EVALUATIONSDIR/cluster_""$PARAMS""_"

    (cd $DIR; matwrapper "try,show_network_stats('$GRAPHFILE','$EVALUATIONSDIR/','$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)
    (cd $DIR; matwrapper "try,partitions_psr('$GRAPHFILE',[70 85],'$TARGET'),catch,exit(1),end,exit(0)" 1> /dev/null)

    if [ "x$MODE" = "xsim" ]; then
      CLUSTERSIZEFILE="$EVALUATIONSDIR/cluster_""$PARAMS""_psr_85_clustersize.csv"
      MAX_CLUSTER=`cat $CLUSTERSIZEFILE | sed "s#,# #g" | tail -n 1 | awk '{print $1}'`
      CLUSTERFILE="$EVALUATIONSDIR/cluster_""$PARAMS""_psr_85_cluster_"$MAX_CLUSTER".csv"
      CLUSTERCSVFILE="$EVALUATIONSDIR/clusterplacement/cluster_""$PARAMS"".csv"
      CLUSTERPLMFILE="$EVALUATIONSDIR/clusterplacement/cluster_""$PARAMS"".plm"
      if [ -e CLUSTERCSVFILE ]; then
        echo "partitionplacement('$CLUSTERFILE','$EVALUATIONSDIR/nodes.plm','$CLUSTERCSVFILE')"
        (cd $DIR; matwrapper "try,partitionplacement('$CLUSTERFILE','$EVALUATIONSDIR/nodes.plm','$CLUSTERCSVFILE'),catch,exit(1),end,exit(0)" 1> /dev/null)
        cat $CLUSTERCSVFILE | sed "s#,# #g" | awk '{print "sk"$0}' > $CLUSTERPLMFILE
      fi
    fi

  done
done
