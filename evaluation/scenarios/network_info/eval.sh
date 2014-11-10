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
  grep "link from" $DATAFILE | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5" "$7}' | grep -v "=" | sort -u > $EVALUATIONSDIR/linksmetric.all
  cat $EVALUATIONSDIR/linksmetric.all | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/linksmetric.mat
fi

NODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}'`

echo "Create linkgraph (Threshold: $THRESHOLD)"

if [ ! -f $EVALUATIONSDIR/graph.txt ]; then

  (cd $DIR; matwrapper "try,metric2graph('$EVALUATIONSDIR/linksmetric.mat','$EVALUATIONSDIR/graph.csv',$THRESHOLD),catch,exit(1),end,exit(0)" 1> /dev/null)
  sed "s#,# #g" $EVALUATIONSDIR/graph.csv > $EVALUATIONSDIR/graph.txt
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
  awk '{print $4}' $RESULTDIR/nodes.mac > $EVALUATIONSDIR/cluster_0.csv
fi

( cd $EVALUATIONSDIR; for i in `ls cluster_*.csv`; do N=`echo $i | sed "s#csv#grp#g"`; cat $i | NUM2NAME=1 human_readable.sh $RESULTDIR/nodes.mac > $N; done )

for i in `(cd $EVALUATIONSDIR; ls cluster_*.csv)`; do
  CLUSTERID=`echo $i | sed "s#_# #g" | sed "s#\.# #g" | awk '{print $2}'`
  echo "Cluster: $CLUSTERID"
  (cd $DIR; matwrapper "try,nodedegree('$EVALUATIONSDIR/$i', '$EVALUATIONSDIR/graph.txt', '$EVALUATIONSDIR/', $CLUSTERID ),catch,exit(1),end,exit(0)" 1> /dev/null)
done

###############################################################################
# placement (sim only)
###############################################################################
#echo $NODEPLACEMENTFILE

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

cat $EVALUATIONSDIR/bcaststats.csv | sed "s#,# #g" | MAC2NUM=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/bcaststats.mat
BCASTSIZE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $3}' | sort -u`
BCASTRATE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $4}' | sort -u`
BCASTNODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}'`

(cd $DIR; matwrapper "try,bcaststats2graph('$EVALUATIONSDIR/bcaststats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)

for r in $BCASTRATE; do
  for s in $BCASTSIZE; do
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

    PARAMS="$r""_""$s"
    TARGET="$EVALUATIONSDIR/cluster_""$PARAMS""_"

    #echo "$GRAPHFILE -> $TARGET"
    #echo "cd $DIR; matwrapper "try,partitions_psr\('$GRAPHFILE',[70 85],'$TARGET'\),catch,exit\(1\),end,exit\(0\)" 1> /dev/null"

    (cd $DIR; matwrapper "try,show_network_stats('$GRAPHFILE','$EVALUATIONSDIR/','$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)
    (cd $DIR; matwrapper "try,partitions_psr('$GRAPHFILE',[70 85],'$TARGET'),catch,exit(1),end,exit(0)" 1> /dev/null)

    #echo "Sim"
    if [ "x$MODE" = "xsim" ]; then
      CLUSTERSIZEFILE="$EVALUATIONSDIR/cluster_""$PARAMS""_psr_85_clustersize.csv"
      MAX_CLUSTER=`cat $CLUSTERSIZEFILE | sed "s#,# #g" | tail -n 1 | awk '{print $1}'`
      CLUSTERFILE="$EVALUATIONSDIR/cluster_""$PARAMS""_psr_85_cluster_"$MAX_CLUSTER".csv"
      CLUSTERCSVFILE="$EVALUATIONSDIR/clusterplacement/cluster_""$PARAMS"".csv"
      CLUSTERPLMFILE="$EVALUATIONSDIR/clusterplacement/cluster_""$PARAMS"".plm"
      if [ -e $CLUSTERFILE ]; then
        #echo "partitionplacement('$CLUSTERFILE','$EVALUATIONSDIR/nodes.plm','$CLUSTERCSVFILE')"
        (cd $DIR; matwrapper "try,partitionplacement('$CLUSTERFILE','$EVALUATIONSDIR/nodes.plm','$CLUSTERCSVFILE'),catch,exit(1),end,exit(0)" 1> /dev/null)
        cat $CLUSTERCSVFILE | sed "s#,# #g" | awk '{print "node"$0}' > $CLUSTERPLMFILE
      fi
    fi
    #echo "Sim end"

  done
done
