#!/bin/sh

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

if [ "x$EVALUATIONSDIR" = "x" ]; then
  EVALUATIONDIR="$RESULTDIR/evaluation"
fi

if [ ! -e $EVALUATIONSDIR ]; then
  mkdir -p $EVALUATIONSDIR
fi

if [ "x$EVALUATION" != "x" ]; then
  for i in $EVALUATION; do
    if [ "x$i" = "xstandard" ]; then
      for d in `(cd $RESULTDIR;ls *.dump)`; do
        if [ "x$MODE"="xsim" ]; then
          ( cd $RESULTDIR; SEQ=yes WIFI=extra $DIR/fromdump.sh $RESULTDIR/$d > $EVALUATIONSDIR/$d.all.dat )
        fi
      done  
      ( cd $EVALUATIONSDIR; RESULTDIR=$RESULTDIR $DIR/../scenarios/standard/eval.sh )
    else
      if [ -f $CONFIGDIR/$i ]; then
        MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $CONFIGDIR/$i
      fi
    fi 
  done
else
  echo "No evaluation"
fi