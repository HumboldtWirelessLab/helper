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
		echo "Use $0 setmarker | statusmarker"
		echo "Use NODELIST"
		echo "Use MARKER"		
		;;
	"setmarker")
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "touch $MARKER; if [ -f /usr/bin/led_ctrl.sh ]; then /usr/bin/led_ctrl.sh setup; fi" "/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		;;
	"statusmarker")	
	        FAILEDNODES=""
		for node in $NODELIST; do
		    RESULT=`run_on_node $node "ls $MARKER" "/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config 2>&1`
		    if [ ! "x$RESULT" = "x$MARKER" ]; then
		        FAILEDNODES="$FAILEDNODES $node"
		    fi
		done

		if [ "x$FAILEDNODES" = "x" ]; then
		    echo "ok"
		else
		    echo "$FAILEDNODES"
		fi
		;;
	"clearmarker")	
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "rm -rf $MARKER" "/" $DIR/../etc/keys/id_dsa $DIR/../etc/keys/ssh_config
		done
		
		echo "ok"
		;;
	
	*)
		$0 help
		;;
esac

exit 0		
