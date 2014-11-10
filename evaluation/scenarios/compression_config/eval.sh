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

if [ ! -f $RESULTDIR/$NAME\_click_scripts.tar.bz2 ]; then
  (cd $RESULTDIR; tar cfj $NAME\_click_scripts.tar.bz2 `cat $NODETABLE | awk '{print $7}' | sed "s#$RESULTDIR/##g" | grep -v -e "^-$" | sort -u`; cat $NODETABLE | awk '{print $7}' | grep -v -e "^-$" | xargs rm -rf )
fi

exit 0

