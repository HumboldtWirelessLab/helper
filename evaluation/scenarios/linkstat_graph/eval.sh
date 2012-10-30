#!/bin/bash

#echo "Eval not valid"

#exit 0

. $CONFIGFILE

if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

THRESHOLD=10000

if [ -f $RESULTDIR/measurement.xml ]; then
  DATAFILE=$RESULTDIR/measurement.xml
else
  if [ -f $EVALUATIONSDIR/measurement.xml ]; then
    DATAFILE=$EVALUATIONSDIR/measurement.xml
  else
    DATAFILE=$RESULTDIR/measurement.log
  fi
fi


cat $DATAFILE | grep "link from" | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5}' | sed -e "s#-##g" | awk '{print "node"strtonum("0x"$1)" node"strtonum("0x"$2)}' | sort -u > $EVALUATIONSDIR/links.all
cat $DATAFILE | grep "link from" | grep -v 'metric="9999"' | sed 's#"# #g' | awk '{print $3" "$5" "$7}' | sed -e "s#-##g" | awk '{print "node"strtonum("0x"$1)" node"strtonum("0x"$2)" "$3}' |sort -u > $EVALUATIONSDIR/linksmetric.all

FULLSED=""
while read line; do
  SRCN=`echo $line | awk '{print $1}'` 
  SRCM=`echo $line | awk '{print $2}' | sed -e "s#-##g"`
  
  FULLSED="$FULLSED -e s#$SRCM#$SRCN#g"
done < $RESULTDIR/nodes.mac

#echo $FULLSED

echo "digraph G {" > $EVALUATIONSDIR/linksmetric.dot.tmp
while read line; do
  SRC=`echo $line | awk '{print $1}'`
  DST=`echo $line | awk '{print $2}'`
    
  METRIC=`cat $EVALUATIONSDIR/linksmetric.all | grep "$SRC $DST" | awk '{print $3}' | sort | head -n 1`
  
  if [ $METRIC -lt $THRESHOLD ]; then
    echo "\"$SRC\" -> \"$DST\"  [label=\"$METRIC\"];" >> $EVALUATIONSDIR/linksmetric.dot.tmp
  fi
  
done < $EVALUATIONSDIR/links.all

echo "}" >> $EVALUATIONSDIR/linksmetric.dot.tmp

cat $EVALUATIONSDIR/linksmetric.dot.tmp | sed $FULLSED > $EVALUATIONSDIR/linksmetric.dot
dot -Tpng $EVALUATIONSDIR/linksmetric.dot > $EVALUATIONSDIR/linksmetric.png


echo "digraph G {" > $EVALUATIONSDIR/links.dot.tmp

cat  $EVALUATIONSDIR/links.all | sort -u | awk '{print "\"" $1 "\" -> \"" $2 "\" [label=\"1\"];"}' >> $EVALUATIONSDIR/links.dot.tmp
echo "}" >> $EVALUATIONSDIR/links.dot.tmp

cat $EVALUATIONSDIR/links.dot.tmp | sed $FULLSED > $EVALUATIONSDIR/links.dot
dot -Tpng $EVALUATIONSDIR/links.dot > $EVALUATIONSDIR/links.png

rm -f $EVALUATIONSDIR/links.dot.tmp $EVALUATIONSDIR/links.dot $EVALUATIONSDIR/linksmetric.dot.tmp $EVALUATIONSDIR/linksmetric.dot