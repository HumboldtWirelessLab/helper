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

if [ "x$MODOPTIONS" = "x" ]; then
    MODOPTIONS=modoptions.default
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
			#ARCH=`get_arch $node $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config`
			ARCH=`run_on_node $node "./system.sh get_arch" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config`
			run_on_node $node "MODULSDIR=\"$DIR/../../nodes/lib/modules/$ARCH\" MODOPTIONS=\"$MODOPTIONS\" ./wlanmodules.sh install" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		    else
			run_on_node $node "MODULSDIR=\"$MODULSDIR\" MODOPTIONS=\"$MODOPTIONS\" ./wlanmodules.sh install" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		    fi
		done
		;;
	"rmmod")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "MODULSDIR=\"$MODULSDIR\" MODOPTIONS=\"$MODOPTIONS\" ./wlanmodules.sh uninstall" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		;;
	"lsmod")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "lsmod" "/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
