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

case "$1" in
	"off")
		$DIR/clewarecontrol -c 1 -as 0 0
		;;
	"on")
		$DIR/clewarecontrol -c 1 -as 0 1
		;;
	*)
		echo "Use $0 on|off"
		;;
esac

exit 0
