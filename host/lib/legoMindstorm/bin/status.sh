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
	"battery")
		$DIR/battery.pl $2
		;;
	"no_power_off")
		$DIR/no_power_off.pl $2
		;;
	*)
		echo "Use $0 on|off"
		;;
esac

exit 0
