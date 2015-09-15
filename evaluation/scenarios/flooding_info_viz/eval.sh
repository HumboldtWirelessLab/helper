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

. $CONFIGFILE

if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

if [ -e $DIR/../../bin/functions.sh ]; then
  . $DIR/../../bin/functions.sh
fi

EVALUATIONSDIR="$EVALUATIONSDIR""/flooding_info"

echo "digraph G {" > $EVALUATIONSDIR/fwd_links.dot.tmp

if [ -e $NODEPLACEMENTFILE ]; then
  USE_NEATO=1
  awk '{printf("\"%s\" [pos=\"%0.f,%0.f!\"];\n",$1,$2/100,$3/100) }' $NODEPLACEMENTFILE >> $EVALUATIONSDIR/fwd_links.dot.tmp
else
  USE_NEATO=0
fi

RESULTDIR="../../"

cat $EVALUATIONSDIR/flooding_lasthop_fwd_pkt_links.mat | awk '{ if ($3 > 0) print "\"<> " $1 " <>\" -> \"<> " $2 " <>\" [label=\""$3"\"];"}' | NUM2NAME=1 human_readable.sh $RESULTDIR/nodes.mac | sed -e "s#<> ##g" -e "s# <>##g" >> $EVALUATIONSDIR/fwd_links.dot.tmp

echo "}" >> $EVALUATIONSDIR/fwd_links.dot.tmp

cat $EVALUATIONSDIR/fwd_links.dot.tmp > $EVALUATIONSDIR/fwd_links.dot

if [ ! -f $EVALUATIONSDIR/fwd_links.png ] || [ ! -f $EVALUATIONSDIR/fwd_links.eps ]; then

  if [ $USE_NEATO -eq 0 ]; then
    dot -Tpng $EVALUATIONSDIR/fwd_links.dot > $EVALUATIONSDIR/fwd_links.png
    dot -Teps $EVALUATIONSDIR/fwd_links.dot > $EVALUATIONSDIR/fwd_links.eps
  else
    neato -Teps $EVALUATIONSDIR/fwd_links.dot > $EVALUATIONSDIR/fwd_links.eps 2> /dev/null
    if [ $? -ne 0 ]; then
      rm -f $EVALUATIONSDIR/fwd_links.eps
      neato -Tpng $EVALUATIONSDIR/fwd_links.dot > $EVALUATIONSDIR/fwd_links.png 2> /dev/null
      if [ $? -ne 0 ]; then
        rm -f $EVALUATIONSDIR/fwd_links.png
        echo "No Images"
      fi
    fi

  fi
fi

rm -f $EVALUATIONSDIR/fwd_links.dot.tmp $EVALUATIONSDIR/fwd_links.dot
