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

EVALUATIONSDIR="$EVALUATIONSDIR""/flooding_info"

if [ ! -e $EVALUATIONSDIR ]; then
  echo "No Inputfile"
  exit 1
fi

(cd $DIR; matwrapper.sh "try,flooding2pdr('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
#echo $?

(cd $DIR; matwrapper.sh "try,flooding_reachability('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
#echo $?

(cd $DIR; matwrapper.sh "try,flooding_forward('$EVALUATIONSDIR/floodingforwardstats.mat','$EVALUATIONSDIR/'),catch,exit(1),end,exit(0)" 1> /dev/null)
#echo $?

for i in `(cd $EVALUATIONSDIR/../network_info; ls graph_psr_*mat)`; do
  PARAMS=`echo $i | sed "s#graph_psr_##g" | sed "s#\.mat##g"`
  (cd $DIR; matwrapper.sh "try,flooding_vs_linkprobing('$EVALUATIONSDIR/flooding_pdr.mat', '$EVALUATIONSDIR/../network_info/$i', '$EVALUATIONSDIR/', '$PARAMS'),catch,exit(1),end,exit(0)" 1> /dev/null)
 # echo $?
done

exit 0
