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

if [ "x$1" != "x" ]; then
  if [ -f $1 ]; then
    . $1
    OLDRESULTDIR=$RESULTDIR
    OLDNODETABLE=`echo $NODETABLE | sed "s#$RESULTDIR#$PWD/#g"`
    cat $1 | sed "s#$RESULTDIR#$PWD/#g" | sed "s#$NODETABLE#$NODETABLE.eval#g" > $1.eval
    . $1.eval
    CONFIGFILE=$PWD/$1.eval
    cat $OLDNODETABLE | sed "s#$OLDRESULTDIR/##g" > $NODETABLE
  else
    echo "$1 not found."
    exit 1
  fi
else
  . $CONFIGFILE
fi

if [ "x$RESULTDIR" = "x" ]; then
  RESULTDIR=$PWD
fi

if [ "x$EVALUATIONDIR" = "x" ]; then
  EVALUATIONDIR="$RESULTDIR/evaluation"
fi

#echo "$RESULTDIR $EVALUATIONDIR"

if [ ! -e $EVALUATIONDIR ]; then
  mkdir -p $EVALUATIONDIR
fi

if [ "x$EVALUATION" != "x" ]; then
  for i in $EVALUATION; do
    if [ -e $DIR/../scenarios/$i ]; then
      ( cd $EVALUATIONDIR; MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $DIR/../scenarios/$i/eval.sh )
    else
      if [ -f $CONFIGDIR/$i ]; then
        ( cd $EVALUATIONDIR; MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $CONFIGDIR/$i )
      fi
    fi
  done
else
  echo "No evaluation"
fi