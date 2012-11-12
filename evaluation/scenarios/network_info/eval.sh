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
while read line; do
  SRCN=`echo $line | awk '{print $1}'`
  SRCID=`echo $line | awk '{print $4}'`

  FULLSED="$FULLSED -e s#^$SRCID\$#$SRCN#g"
done < $RESULTDIR/nodes.mac

###############################################################################
# create linkmetric.all
###############################################################################
echo "Create linkmetric matrix"

THRESHOLD=3000

if [ ! -f $EVALUATIONSDIR/linksmetric.all ]; then
  cat $DATAFILE | grep "link from" | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5" "$7}' | grep -v "=" | sort -u > $EVALUATIONSDIR/linksmetric.all
fi

NODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}'`

echo "Create linkgraph (Threshold: $THRESHOLD)"

if [ ! -f $EVALUATIONSDIR/graph.txt ]; then
  echo -n "" > $EVALUATIONSDIR/graph.txt

  for n in $NODES; do
    for m in $NODES; do
      METRIC=`cat $EVALUATIONSDIR/linksmetric.all | grep "$n $m" | awk '{print $3}' | sort | head -n 1`

      #echo "$n $m $METRIC" >> $EVALUATIONSDIR/foundmetric.txt

      LINK=1
      if [ "x$METRIC" = "x" ]; then
        LINK=0
      else
        if [ $METRIC -lt $THRESHOLD ]; then
          LINK=1
        else
          LINK=0
        fi
      fi

      echo -n "$LINK " >> $EVALUATIONSDIR/graph.txt
    done
    echo "" >> $EVALUATIONSDIR/graph.txt
  done
fi

###############################################################################
# create partition (etx linktable based)
###############################################################################

echo "Create partitions files"

(cd $DIR; matlab -nosplash -nodesktop -r "try,partitions('$EVALUATIONSDIR/graph.txt','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi

echo "Create clusterfiles and nodedegree!"

if [ ! -f $EVALUATIONSDIR/cluster_0.csv ]; then
  #create cluster file for hole network
  cat $RESULTDIR/nodes.mac | awk '{print $4}' > $EVALUATIONSDIR/cluster_0.csv
fi

( cd $EVALUATIONSDIR; for i in `ls cluster_*.csv`; do N=`echo $i | sed "s#csv#grp#g"`; cat $i | sed $FULLSED > $N; done )

for i in `(cd $EVALUATIONSDIR; ls cluster_*.csv)`; do
  CLUSTERID=`echo $i | sed "s#_# #g" | sed "s#\.# #g" | awk '{print $2}'`
  echo "Cluster: $CLUSTERID"
  (cd $DIR; matlab -nosplash -nodesktop -r "try,nodedegree('$EVALUATIONSDIR/$i', '$EVALUATIONSDIR/graph.txt', '$EVALUATIONSDIR/', $CLUSTERID ),catch,exit(1),end,exit(0)" 1> /dev/null)
done

###############################################################################
# bcaststats
###############################################################################

echo "Create bcaststats!"

if [ ! -f $EVALUATIONSDIR/bcaststats.csv ]; then
  xsltproc $DIR/bcaststats.xslt $DATAFILE > $EVALUATIONSDIR/bcaststats.csv
fi

echo "Networkstats!"

BCASTSIZE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $3}' | sort -u`
BCASTRATE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $4}' | sort -u`
BCASTNODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}'`

for r in $BCASTRATE; do
  for s in $BCASTSIZE; do
    GRAPHFILE="$EVALUATIONSDIR/graph_psr_$r""_""$s.txt"

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

    (cd $DIR; matlab -nosplash -nodesktop -r "try,show_network_stats('$GRAPHFILE','$EVALUATIONSDIR/','$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)

  done
done
