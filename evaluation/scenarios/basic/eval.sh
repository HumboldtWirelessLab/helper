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

for d in `(cd $RESULTDIR;ls *.dump)`; do
    if [ "x$MODE"="xsim" ]; then
      ( cd $RESULTDIR; SEQ=yes WIFI=extra $DIR/../../bin/fromdump.sh $RESULTDIR/$d > $EVALUATIONDIR/$d.all.dat )
    fi
done  


exit 0