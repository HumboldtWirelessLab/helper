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
		echo "Use $0 reboot | status"
		echo "Use NODELIS"
		;;
	"reboot")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "reboot" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"status")	
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "uptime" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"waitfornodes")
		for node in $NODELIST; do
		    AVAILABLE=`node_available $node`
		    while [ $AVAILABLE = "n" ]; do
			sleep 1;
			AVAILABLE=`node_available $node`
		    done
		done
		;;	    
	*)
		$0 help
		;;
esac

exit 0		
