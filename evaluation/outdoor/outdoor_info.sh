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

SENDERNUM=0

if [ "x$1" = "x" ]; then
    echo "use $0 DATADIR"
    exit 0
fi

DATADIR=$1

if [ "x$RESULTDIR" = "x" ]; then                                                                                                                                                                                 
    RESULTDIR=$DATADIR\_evaluation                                                                                                                                                                               
fi  

rm -f $RESULTDIR/info.log.tmp

for i in `ls $DATADIR`; do
    if [ -e $DATADIR/$i/info ]; then
	echo -n "$i: " >> $RESULTDIR/info.log.tmp
	cat $DATADIR/$i/info >> $RESULTDIR/info.log.tmp
	echo "" >> $RESULTDIR/info.log.tmp
    fi

done

cat $RESULTDIR/info.log.tmp | egrep -v "^[[:space:]]*$" > $RESULTDIR/info.log
rm -f $RESULTDIR/info.log.tmp

exit 0
