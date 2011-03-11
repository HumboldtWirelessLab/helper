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


case "$1" in
	"forward")
		$DIR/forward.pl $2
		;;
	"backward")
		$DIR/backward.pl $2
		;;
	*)
		echo "Use $0 on|off"
		;;
esac

exit 0
