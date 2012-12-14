#!/bin/bash

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

THRESHOLD=3000

FULLSED=""
while read line; do
  SRCN=`echo $line | awk '{print $1}'` 
  SRCM=`echo $line | awk '{print $3}'`

  FULLSED="$FULLSED -e s#$SRCM#$SRCN#g"
done < $RESULTDIR/nodes.mac

EVALUATIONSDIR="$EVALUATIONSDIR""/linkstat_graph"
if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi


cat $DATAFILE | grep "link from" | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5}' | grep -v "=" | sort -u > $EVALUATIONSDIR/links.all
cat $DATAFILE | grep "link from" | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5" "$7}' | grep -v "=" | sort -u > $EVALUATIONSDIR/linksmetric.all

echo "digraph G {" > $EVALUATIONSDIR/linksmetric.dot.tmp
echo "digraph G {" > $EVALUATIONSDIR/links.dot.tmp

NODES=`cat $RESULTDIR/nodes.mac | awk '{print $3}' | sort -u`

if [ -e $RESULTDIR/placementfile.plm ]; then
  USE_NEATO=1
  for n in $NODES; do
    NODENAME=`cat $RESULTDIR/nodes.mac | grep $n | awk '{print $1}'`
    X=`cat $RESULTDIR/placementfile.plm | grep "$NODENAME " | awk '{print $2}'`
    X=`calc $X / 50 | sed "s#^[[:space:]]*~##g"`
    Y=`cat $RESULTDIR/placementfile.plm | grep "$NODENAME " | awk '{print $3}'`
    Y=`calc $Y / 50 | sed "s#^[[:space:]]*~##g"`
    echo "\"$n\" [pos=\"$X,$Y!\"];" >> $EVALUATIONSDIR/links.dot.tmp
    echo "\"$n\" [pos=\"$X,$Y!\"];" >> $EVALUATIONSDIR/linksmetric.dot.tmp
  done
else
  USE_NEATO=0
fi

CURRLINE=1

while read line; do
  SRC=`echo $line | awk '{print $1}'`
  DST=`echo $line | awk '{print $2}'`

  METRIC=`cat $EVALUATIONSDIR/linksmetric.all | grep "$SRC $DST" | awk '{print $3}' | sort | head -n 1`

  if [ "x$SRC" != "x" ] && [ "x$DST" != "x" ] && [ "x$METRIC" != "x" ]; then

    if [ $METRIC -lt $THRESHOLD ]; then
      echo "\"$SRC\" -> \"$DST\"  [label=\"$METRIC\"];" >> $EVALUATIONSDIR/linksmetric.dot.tmp
    fi
  else
    echo "ERROR! Incomplete linkinfo: SRC: $SRC DST: $DST METRIC: $METRIC Line: $CURRLINE !"
  fi

  let CURRLINE=CURRLINE+1

done < $EVALUATIONSDIR/links.all


cat  $EVALUATIONSDIR/links.all | sort -u | awk '{print "\"" $1 "\" -> \"" $2 "\" [label=\"1\"];"}' >> $EVALUATIONSDIR/links.dot.tmp

echo "}" >> $EVALUATIONSDIR/linksmetric.dot.tmp
echo "}" >> $EVALUATIONSDIR/links.dot.tmp


cat $EVALUATIONSDIR/links.dot.tmp | sed $FULLSED > $EVALUATIONSDIR/links.dot
cat $EVALUATIONSDIR/linksmetric.dot.tmp | sed $FULLSED > $EVALUATIONSDIR/linksmetric.dot

if [ ! -f $EVALUATIONSDIR/linksmetric.png ] || [ ! -f $EVALUATIONSDIR/linksmetric.eps ] || [ ! -f $EVALUATIONSDIR/links.png ] || [ ! -f $EVALUATIONSDIR/links.eps ]; then

  if [ $USE_NEATO -eq 0 ]; then
    dot -Tpng $EVALUATIONSDIR/linksmetric.dot > $EVALUATIONSDIR/linksmetric.png
    dot -Tpng $EVALUATIONSDIR/links.dot > $EVALUATIONSDIR/links.png
    dot -Teps $EVALUATIONSDIR/linksmetric.dot > $EVALUATIONSDIR/linksmetric.eps
    dot -Teps $EVALUATIONSDIR/links.dot > $EVALUATIONSDIR/links.eps
  else
    neato -Teps $EVALUATIONSDIR/links.dot > $EVALUATIONSDIR/links.eps 2> /dev/null
    if [ $? -ne 0 ]; then
      rm -f $EVALUATIONSDIR/links.eps
      neato -Tpng $EVALUATIONSDIR/links.dot > $EVALUATIONSDIR/links.png 2> /dev/null
      if [ $? -ne 0 ]; then
        rm -f $EVALUATIONSDIR/links.png
        echo "No Images"
      fi
    fi

    neato -Teps $EVALUATIONSDIR/linksmetric.dot > $EVALUATIONSDIR/linksmetric.eps 2> /dev/null

    if [ $? -ne 0 ]; then
      rm -f $EVALUATIONSDIR/linksmetric.eps
      neato -Tpng $EVALUATIONSDIR/linksmetric.dot > $EVALUATIONSDIR/linksmetric.png 2> /dev/null
      if [ $? -ne 0 ]; then
        rm -f $EVALUATIONSDIR/linksmetric.png
      fi
    fi
  fi
fi

rm -f $EVALUATIONSDIR/links.dot.tmp $EVALUATIONSDIR/links.dot $EVALUATIONSDIR/linksmetric.dot.tmp $EVALUATIONSDIR/linksmetric.dot $EVALUATIONSDIR/links.all $EVALUATIONSDIR/linksmetric.all
#$EVALUATIONSDIR/conn.mat
