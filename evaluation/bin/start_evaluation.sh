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


function handle_eval {

  local i=""

  for i in $@; do

    EVAL_DONE=`cat $EVALUATION_DONE_FILE | grep -e "^${i}" | wc -l`

    if [ $EVAL_DONE -eq 0 ]; then

      if [ -e $DIR/../scenarios/$i ]; then
        if [ -e $DIR/../scenarios/$i/.depends ]; then
          handle_eval `cat $DIR/../scenarios/$i/.depends`
        fi

        if [ -f $DIR/../scenarios/$i/eval.sh ]; then
          ( cd $EVALUATIONDIR; MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $DIR/../scenarios/$i/eval.sh )
          RESULT=$?
          if [ $RESULT -ne 0 ]; then
            exit 2
          fi
        fi
      else
        EVALDIR=`dirname $CONFIGDIR/$i`
        if [ -e $EVALDIR/.depends ]; then
          handle_eval `cat $EVALDIR/.depends`
        fi

        if [ -f $CONFIGDIR/$i ]; then
          ( cd $EVALUATIONDIR; MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $CONFIGDIR/$i )
          RESULT=$?
          if [ $RESULT -ne 0 ]; then
            exit 2
          fi
        fi
      fi

      echo "$i" >> $EVALUATION_DONE_FILE
    #else
    #  echo "$i already done"
    fi
  done

}

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
    exit 2
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

if [ "x$REWRITEEVALUATION" != "x" ]; then
  EVALUATION=$REWRITEEVALUATION
fi

EVALUATION_DONE_FILE=$EVALUATIONDIR/.evaluation_done

echo -n "" > $EVALUATION_DONE_FILE

EVALUATION="$PREEVALUATION $EVALUATION $ADDEVALUATION"

if [ "x$EVALUATION" != "x" ]; then
  handle_eval "$EVALUATION"
else
  echo "No evaluation"
fi

exit 0
