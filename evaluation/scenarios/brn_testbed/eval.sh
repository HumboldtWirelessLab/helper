#!/bin/bash

rm -f links.all

for i in `ls *.log`; do
  cat $i | grep "00-" | awk '{print $1" "$2}' | sed -e "s#-##g" >> links.all.tmp
  cat $i | grep "00-" | awk '{print $1" "$2" "$3}' | sed -e "s#-##g" >> linksmetric.all
done

cat links.all.tmp | sort -u > links.all
rm links.all.tmp

cat links.all | awk '{print $1}' | sort -u | awk '{print $1" "NR}' > node.all
echo "digraph G {" > links.uni
cat links.all | sort -u | awk '{print "\"" $1 "\" -> \"" $2 "\" [label=\"1\"];"}' >> links.uni
echo "}" >> links.uni

#while read line; do
#  OLD=`echo $line | awk '{print $1}'`
#  NEW=`echo $line | awk '{print $2}'`
#  cat links.uni | sed -e "s#$OLD#$NEW#g" > links.uni.old
#  rm links.uni
#  mv links.uni.old links.uni
#done < node.all

dot -Tpng links.uni > links.png

echo "digraph G {" > linksmetric.uni
while read line; do
  SRC=`echo $line | awk '{print $1}'`
  DST=`echo $line | awk '{print $2}'`
  METRIC=`cat linksmetric.all | grep "$SRC $DST" | awk '{print $3}' | sort | head -n 1`
  if [ $METRIC -lt 9999 ]; then
    echo "\"$SRC\" -> \"$DST\"  [label=\"$METRIC\"];" >> linksmetric.uni
  fi
done < links.all
echo "}" >> linksmetric.uni

dot -Tpng linksmetric.uni > linksmetric.png
