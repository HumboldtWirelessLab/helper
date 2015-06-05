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

EVALUATIONSDIR="$EVALUATIONSDIR""/network_info"

echo "digraph G {" > $EVALUATIONSDIR/linksmetric.dot.tmp
echo "digraph G {" > $EVALUATIONSDIR/links.dot.tmp

if [ -e $NODEPLACEMENTFILE ]; then
  USE_NEATO=1
  awk '{printf("\"%s\" [pos=\"%0.f,%0.f!\"];\n",$1,$2/50,$3/50) }' $NODEPLACEMENTFILE >> $EVALUATIONSDIR/linksmetric.dot.tmp
  awk '{printf("\"%s\" [pos=\"%0.f,%0.f!\"];\n",$1,$2/50,$3/50) }' $NODEPLACEMENTFILE >> $EVALUATIONSDIR/links.dot.tmp
else
  USE_NEATO=0
fi

cat $EVALUATIONSDIR/linksmetric.all | grep -v " 0\$" | awk '{ if ($3 < 1000) print "\"" $1 "\" -> \"" $2 "\" [label=\"1\"];"}' >> $EVALUATIONSDIR/links.dot.tmp
cat $EVALUATIONSDIR/linksmetric.all | grep -v " 0\$" | awk '{ if ($3 < 1000) print "\"" $1 "\" -> \"" $2 "\" [label=\"" $3 "\"];"}' >> $EVALUATIONSDIR/linksmetric.dot.tmp

echo "}" >> $EVALUATIONSDIR/linksmetric.dot.tmp
echo "}" >> $EVALUATIONSDIR/links.dot.tmp


cat $EVALUATIONSDIR/links.dot.tmp | MAC2NAME=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/links.dot
cat $EVALUATIONSDIR/linksmetric.dot.tmp | MAC2NAME=1 human_readable.sh $RESULTDIR/nodes.mac > $EVALUATIONSDIR/linksmetric.dot

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

rm -f $EVALUATIONSDIR/links.dot.tmp $EVALUATIONSDIR/links.dot $EVALUATIONSDIR/linksmetric.dot.tmp $EVALUATIONSDIR/linksmetric.dot

HAS_BCAST_STATS=`du -s $EVALUATIONSDIR/bcaststats.mat | awk '{print $1}'`

if [ $HAS_BCAST_STATS -ne 0 ]; then
  for i in `(cd $EVALUATIONSDIR/; ls graph_psr_*_*.mat)`; do
    PARAMS=`echo $i | sed -e "s#graph_psr_##g" -e "s#\.mat##g"`
    #echo "$PARAMS"
    (cd $DIR; matwrapper "try,show_network_stats('$GRAPHFILE','$EVALUATIONSDIR/','$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)
  done

  (cd $DIR; matwrapper "try,nodedegree_plot('$EVALUATIONSDIR/graph_psr.mat', [25 50 75], '$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
fi