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
		echo "Use NODELIST"
		;;
	"reboot")
		for node in $NODELIST; do
		    echo -n "$node: "
		    DENYREBOOT=`cat $DIR/../etc/reboot.deny | grep -e "^$node$" | wc -l`
		    if [ $DENYREBOOT -eq 1 ]; then
		      echo "Reboot not allowed !"
		    else
		      echo "Reboot"
		      run_on_node $node "reboot" "/" $DIR/../etc/keys/id_dsa
		    fi  
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
		    echo "$node"
		    AVAILABLE=`node_available $node`
		    while [ $AVAILABLE = "n" ]; do
			sleep 1;
			AVAILABLE=`node_available $node`
		    done
		done
		;;	    
	"waitfornodesandssh")
		for node in $NODELIST; do
		
		    AVAILABLE=`node_available $node`
		    while [ $AVAILABLE = "n" ]; do
			sleep 5;
			AVAILABLE=`node_available $node`
		    done

		    ARCH=`run_on_node $node "uname -m" "/" $DIR/../etc/keys/id_dsa 2> /dev/null`
		    while [ "x$ARCH" = "x" ]; do
 			sleep 10;
			ARCH=`run_on_node $node "uname -m" "/" $DIR/../etc/keys/id_dsa 2> /dev/null`
		    done

		done
		;;	    
	*)
		$0 help
		;;
esac

exit 0		
