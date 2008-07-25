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


if [ "x$1" = "x" ]; then
    echo "use $0 DATADIR"
    exit 0
fi

DATADIR=`echo $1 | sed -e "s/[\/]*$//g"`

if [ "x$RESULTDIR" = "x" ]; then
    RESULTDIR=$DATADIR\_evaluation
fi

mkdir -p $RESULTDIR

for i in `ls $DATADIR`; do

    echo "POINT $i "    

    AC_EVALUATIONDIR=$RESULTDIR/$i/

    if [ ! -e $AC_EVALUATIONDIR ]; then
         mkdir -p $AC_EVALUATIONDIR
    fi

    DUMPS=`(cd $DATADIR/$i/; ls *.dump 2> /dev/null )`
    for receiver in $DUMPS; do

	NODE=`echo $receiver | sed "s#\.# #g" | awk '{print $1}'`
	DEVICE=`echo $receiver | sed "s#\.# #g" | awk '{print $2}'`

	if [ ! -e $AC_EVALUATIONDIR/$NODE\_$DEVICE.mat ]; then
	    cat $DIR/outdoor_evaluation_804.click | sed -e "s#NODE#$NODE#g" -e "s#DEVICE#$DEVICE#g" -e "s#POINT#$i#g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.click

    	    (cd $DATADIR/$i; click-align $AC_EVALUATIONDIR/$NODE.$DEVICE.click 2>&1 | grep -v "warning: added" | click 2>&1 | grep -v "^[[:space:]]*$" | sed -e "s#click.*router##g" > $AC_EVALUATIONDIR/$NODE\_$DEVICE.mat.pre)
	    cat $AC_EVALUATIONDIR/$NODE\_$DEVICE.mat.pre |  grep -v "^[[:space:]]*$" | sed -e "s#sk11##g" -e "s#ath##g" | awk '{print $1" "$2" "$3" "$5" "$6" "$7" "$8" "$14" "$15" "$16" "$17" "$18" "$19" "$20}' > $AC_EVALUATIONDIR/$NODE\_$DEVICE.dat
	    cat $AC_EVALUATIONDIR/$NODE\_$DEVICE.dat >> $RESULTDIR/all.dat
	fi

    done
done

exit 0

