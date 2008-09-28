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

case "$1" in
	"help")
		echo "Use $0 mount | watchdogstart | status"
		echo "Use NODELIST"
		;;
	"mount")
		for node in $NODELIST; do
		    echo "$node"
		    
		    ENVIRONMENTFILE=`cat $DIR/../../nodes/etc/environment/nodesenvironment.conf | grep "^$node" | awk '{print $2}'`
		    . $DIR/../../nodes/etc/environment/$ENVIRONMENTFILE
		    
		    run_on_node $node "mount -o nolock $NFSSERVER:$NFSHOME $NFSHOME" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"watchdogstart")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "/etc/init.d/watchdog start" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"settime")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "$DIR/../../nodes/bin/" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
