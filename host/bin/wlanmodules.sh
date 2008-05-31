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

if [ "x$NODELIST" = "x" ]; then
    ls  $DIR/../etc/nodegroups/
fi

if [ "x$OPTIONSCONF" = "x" ]; then
    MODOPTIONS=""
fi

case "$1" in
	"help")
		echo "Use $0 rmmod | insmod | lsmod"
		echo "Use NODELIST"
		;;
	"insmod")
		for node in $NODELIST; do
		    echo "$node"
		    if [ "x$MODULSDIR" = "x" ]; then
			ARCH=`get_arch $node $DIR/../etc/keys/id_dsa`
			run_on_node $node "MODULSDIR=\"$DIR/../../nodes/lib/modules/$ARCH\" MODOPTIONS=\"$MODOPTIONS\" ./wlanmodules.sh install" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa
		    else
			run_on_node $node "MODULSDIR=\"$MODULSDIR\" MODOPTIONS=\"$MODOPTIONS\" ./wlanmodules.sh install" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa
		    fi
		done
		;;
	"rmmod")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "./wlanmodules.sh uninstall" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa
		done
		;;
	"lsmod")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "lsmod" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
