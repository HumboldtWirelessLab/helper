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

. $DIR/functions.sh


case "$1" in
	"help")
		echo "Use $0 insmod"
		echo "Use NODELIST"
		;;
	"insmod")
		for node in $NODELIST; do
		    echo "$node"
		    if [ !  "x$MODULSDIR" = "x" ]; then
			run_on_node $node "insmod ./proclikefs.ko; insmod ./click.ko; mkdir /tmp/click; mount -t click none /tmp/click" "$MODULSDIR" $DIR/../etc/keys/id_dsa
		    fi
		done
		;;
	"rmmod")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "rmmod click procelikefs" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
