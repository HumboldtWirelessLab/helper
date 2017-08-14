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

echo "digraph G {" > $EVALUATIONSDIR/fwd_links.dot

if [ -e $NODEPLACEMENTFILE ]; then
  USE_NEATO=1
  awk '{printf("\"%s\" [pos=\"%0.f,%0.f!\"];\n",$1,$2/100,$3/100) }' $NODEPLACEMENTFILE >> $EVALUATIONSDIR/fwd_links.dot
else
  USE_NEATO=0
fi

cat $EVALUATIONSDIR/flooding_lasthop_fwd_pkt_links.mat | awk '{ if ($3 > 0) print "\"<> " $1 " <>\" -> \"<> " $2 " <>\" [label=\""$3"\"];"}' | NUM2NAME=1 human_readable.sh $RESULTDIR/nodes.mac | sed -e "s#<> ##g" -e "s# <>##g" >> $EVALUATIONSDIR/fwd_links.dot

echo "}" >> $EVALUATIONSDIR/fwd_links.dot


DOTFILE=resp_graph.dot

echo "digraph G {" > $EVALUATIONSDIR/$DOTFILE

if [ -e $NODEPLACEMENTFILE ]; then
  USE_NEATO=1
  awk '{printf("\"%s\" [pos=\"%0.f,%0.f!\"];\n",$1,$2/100,$3/100) }' $NODEPLACEMENTFILE >> $EVALUATIONSDIR/$DOTFILE
else
  USE_NEATO=0
fi


cat $EVALUATIONSDIR/floodingforwardstats.mat | awk '{ if ($15 == 1) print $2" "$1;}' | sort -n | uniq -c | awk '{print "\"<> " $2 " <>\" -> \"<> " $3 " <>\" [label=\""$1"\"];"}' | NUM2NAME=1 human_readable.sh $RESULTDIR/nodes.mac | sed -e "s#<> ##g" -e "s# <>##g" >> $EVALUATIONSDIR/$DOTFILE

echo "}" >> $EVALUATIONSDIR/$DOTFILE



if [ ! -f $EVALUATIONSDIR/fwd_links.png ] || [ ! -f $EVALUATIONSDIR/fwd_links.eps ]; then

  if [ $USE_NEATO -eq 0 ]; then
    dot -Tpng $EVALUATIONSDIR/fwd_links.dot > $EVALUATIONSDIR/fwd_links.png
    dot -Teps $EVALUATIONSDIR/fwd_links.dot > $EVALUATIONSDIR/fwd_links.eps
  else
    neato -Teps $EVALUATIONSDIR/fwd_links.dot > $EVALUATIONSDIR/fwd_links.eps 2> /dev/null
    neato -Teps $EVALUATIONSDIR/resp_graph.dot > $EVALUATIONSDIR/fwd_resp.eps 2> /dev/null
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


rm -f $EVALUATIONSDIR/fwd_links.dot $EVALUATIONSDIR/resp_graph.dot
