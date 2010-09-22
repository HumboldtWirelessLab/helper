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

if [ "x$EVALUATIONDIR" = "x" ]; then
  EVALUATIONDIR="$RESULTDIR/evaluation"
fi

if [ ! -e $EVALUATIONDIR ]; then
  mkdir -p $EVALUATIONDIR
fi

if [ "x$EVALUATION" != "x" ]; then
  for i in $EVALUATION; do
    if [ -e $DIR/../scenarios/$i ]; then
      ( cd $EVALUATIONDIR; MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $DIR/../scenarios/$i/eval.sh )
    else
      if [ -f $CONFIGDIR/$i ]; then
        MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $CONFIGDIR/$i
      fi
    fi 
  done
else
  echo "No evaluation"
fi