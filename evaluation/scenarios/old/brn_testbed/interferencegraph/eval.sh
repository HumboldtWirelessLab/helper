#!/bin/bash

NODES=`cat $1 | awk '{print $1}' | sort -u`

echo "digraph G {" > ig.txt

for n in $NODES; do
  for m in $NODES; do
    if [ $m != $n ]; then
      BWN=`cat $1 | grep "$n none" | awk '{print $3}'`
      BWM=`cat $1 | grep "$m none" | awk '{print $3}'`
      
      BWNMN1=`cat $1 | grep "$n $m" | awk '{print $3}'`
      BWNMN2=`cat $1 | grep "$m $n" | awk '{print $4}'`
      BWNMM1=`cat $1 | grep "$n $m" | awk '{print $4}'`
      BWNMM2=`cat $1 | grep "$m $n" | awk '{print $3}'`

      BWNMN=`expr $BWNMN1 + $BWNMN2`
      BWNMM=`expr $BWNMM1 + $BWNMM2`
      
      BWNI=`expr \( 1000 \* $BWN \) / $BWNMN`
      BWMI=`expr \( 1000 \* $BWM \) / $BWNMM`
      
      I=`expr \( $BWNI + $BWMI \) / 2`
      
      if [ $I -gt 500 ]; then
        echo "\"$n\" -> \"$m\"  [label=\"$I\"];" >> ig.txt
      fi
    fi
  done
done

echo "}" >> ig.txt

dot -Tpng ig.txt > ig.png
