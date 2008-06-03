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
	"help")
		echo "Use $0 run"
		;;
	"run")
		;;
	*)
		$0 help
		;;
esac

exit 0		
