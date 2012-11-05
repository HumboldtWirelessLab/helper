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

xsltproc $DIR/bcaststats.xslt $DATAFILE > $EVALUATIONSDIR/bcaststats.csv

BCASTSIZE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $3}' | sort -u`
BCASTRATE=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $4}' | sort -u`
BCASTNODES=`cat $EVALUATIONSDIR/bcaststats.csv | awk -F , '{print $1}' | sort -u`

for r in $BCASTRATE; do
  for s in $BCASTSIZE; do
   GRAPHFILE="$EVALUATIONSDIR/graph_psr_$r""_""$s.txt"
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
  done
done

THRESHOLD=3000

cat $DATAFILE | grep "link from" | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5" "$7}' | grep -v "=" | sort -u > $EVALUATIONSDIR/linksmetric.all

NODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}' | sort -u`

if [ ! -f $EVALUATIONSDIR/graph.txt ]; then
  echo -n "" > $EVALUATIONSDIR/graph.txt

  for n in $NODES; do
    for m in $NODES; do
      METRIC=`cat $EVALUATIONSDIR/linksmetric.all | grep "$n $m" | awk '{print $3}' | sort | head -n 1`

      LINK=1
      if [ "x$METRIC" = "x" ]; then
        LINK=0
      else
        LINK=1
      fi

      echo -n "$LINK " >> $EVALUATIONSDIR/graph.txt
    done
    echo "" >> $EVALUATIONSDIR/graph.txt
  done
fi

(cd $DIR; matlab -nosplash -nodesktop -nojvm -r "partitions('$EVALUATIONSDIR/graph.txt','$EVALUATIONSDIR/');exit" 1> /dev/null)

FULLSED=""
while read line; do
  SRCN=`echo $line | awk '{print $1}'`
  SRCID=`echo $line | awk '{print $4}'`

  FULLSED="$FULLSED -e s#^$SRCID\$#$SRCN#g"
done < $RESULTDIR/nodes.mac

#create cluster file for hole network
cat $RESULTDIR/nodes.mac | awk '{print $4}' > $EVALUATIONSDIR/cluster_0.csv

( cd $EVALUATIONSDIR; for i in `ls cluster_*.csv`; do N=`echo $i | sed "s#csv#grp#g"`; cat $i | sed $FULLSED > $N; done )

#for i in `(cd $EVALUATIONSDIR; ls cluster_*.csv)`; do
#  (cd $DIR; matlab -nosplash -nodesktop -nojvm -r "nodedegree('$EVALUATIONSDIR/$i', '$EVALUATIONSDIR/graph.txt');exit" 1> /dev/null)
#done
