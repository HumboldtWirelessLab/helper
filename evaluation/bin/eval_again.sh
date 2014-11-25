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

if [ "x$1" = "x" ]; then
  DESFILE=`ls *.des.sim`
else
  DESFILE=$1
fi

. $DESFILE


# REWRITEEVALUATION : use complete diff eval scripts
# PREEVALUATION : run before eval
# ADDEVALUATION : run after eval

if [ "x$DEFAULT_USED_SIMULATOR" != "x" ]; then
  MODE=sim
  SIM=$DEFAULT_USED_SIMULATOR
fi

CONFIGDIR=$CONFIGDIR

CONFIGFILE=`(cd $RESULTDIR; ls *.des.sim)`
CONFIGFILE=$RESULTDIR/$CONFIGFILE

MODE=$MODE SIM=$SIM CONFIGDIR=$CONFIGDIR CONFIGFILE=$CONFIGFILE RESULTDIR=$RESULTDIR $DIR/start_evaluation.sh 1>&1

exit $?

