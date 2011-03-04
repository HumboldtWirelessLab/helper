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

export PERL5LIB=$DIR/../lib
export RCX_PORT="usb"
export NQC_OPTIONS="-Trcx2"

if [ "x$1" = "x" ]; then
  BEEP=0
else
  BEEP=$1
fi

$DIR/beep.pl $BEEP

exit 0
