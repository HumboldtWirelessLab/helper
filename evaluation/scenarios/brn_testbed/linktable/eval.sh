#!/bin/bash

THRESHOLD=10000

cat $1 | grep "-" | awk '{print $1" "$2}' | sed -e "s#-##g" | sort -u > links.all
cat $1 | grep "-" | awk '{print $1" "$2" "$3}' | sed -e "s#-##g" | sort -u > linksmetric.all

FULLSED=""
while read line; do
  SRCN=`echo $line | awk '{print $1}'` 
  SRCM=`echo $line | awk '{print $3}' | sed -e "s#:##g"`
  
  FULLSED="$FULLSED -e s#$SRCM#$SRCN#g"
done < $2

echo $FULLSED

echo "digraph G {" > linksmetric.dot.tmp
while read line; do
  SRC=`echo $line | awk '{print $1}'`
  DST=`echo $line | awk '{print $2}'`
    
  METRIC=`cat linksmetric.all | grep "$SRC $DST" | awk '{print $3}' | sort | head -n 1`
  
  if [ $METRIC -lt $THRESHOLD ]; then
    echo "\"$SRC\" -> \"$DST\"  [label=\"$METRIC\"];" >> linksmetric.dot.tmp
  fi
  
done < links.all

echo "}" >> linksmetric.dot.tmp

cat linksmetric.dot.tmp | sed $FULLSED > linksmetric.dot
dot -Tpng linksmetric.dot > linksmetric.png


echo "digraph G {" > links.dot.tmp

cat links.all | sort -u | awk '{print "\"" $1 "\" -> \"" $2 "\" [label=\"1\"];"}' >> links.dot.tmp
echo "}" >> links.dot.tmp

cat links.dot.tmp | sed $FULLSED > links.dot
dot -Tpng links.dot > links.png
