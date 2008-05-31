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
		    run_on_node $node "touch $MARKER" "/" $DIR/../etc/keys/id_dsa
		done
		;;
	"statusmarker")	
		for node in $NODELIST; do
		    RESULT=`run_on_node $node "ls $MARKER" "/" $DIR/../etc/keys/id_dsa`
		    if [ ! "x$RESULT" = "x$MARKER" ]; then
			echo "failed"
			exit 0
		    fi
		done
		
		echo "ok"
		;;
	"clearmarker")	
		for node in $NODELIST; do
		    echo "$node"
		    run_on_node $node "rm -rf $MARKER" "/" $DIR/../etc/keys/id_dsa
		done
		
		echo "ok"
		;;
	
	*)
		$0 help
		;;
esac

exit 0		
