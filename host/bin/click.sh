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
			    run_on_node $node "MODULSDIR=$MODULSDIR ./click.sh install" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		    fi
		done
		;;
	"rmmod")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "MODULSDIR=$MODULSDIR ./click.sh uninstall" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		;;
	"reloadmod")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "MODULSDIR=$MODULSDIR ./click.sh reinstall" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		;;
	"kclick_stop")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "MODULSDIR=$MODULSDIR ./click.sh kclick_stop" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		;;
	"stop")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "MODULSDIR=$MODULSDIR ./click.sh stop" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
