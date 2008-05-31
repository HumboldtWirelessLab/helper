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

if [ "x$DEVICES" = "x" ]; then
    DEVICES="ath0"
fi

case "$1" in
	"help")
		echo "Use $0 create | delete | config"
		echo "Use DEVICES , NODE and CONFIG"
		;;
	"create")
		if [ "x$NODE" = "x" ]; then
		    echo "use NODE to set the node"
		    exit 0
		fi
		for device in $DEVICES; do
		    echo "create $NODE $device"
		    run_on_node $NODE "CONFIG=$CONFIG DEVICE=$device ./wlandevice.sh create" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa
		done
		;;
	"delete")
		if [ "x$NODE" = "x" ]; then
		    echo "use NODE to set the node"
		    exit 0
		fi
		for device in $DEVICES; do
		    echo "delete $NODE $device"
		    run_on_node $NODE "DEVICE=$device ./wlandevice.sh delete" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa
		done
		;;
	"config")
		if [ "x$NODE" = "x" ]; then
		    echo "use NODE to set the node"
		    exit 0
		fi
		for device in $DEVICES; do
		    echo "config $NODE $device"
		    run_on_node $NODE "CONFIG=$CONFIG DEVICE=$device ./wlandevice.sh config" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa
		done
		;;
	"start")
		if [ "x$NODE" = "x" ]; then
		    echo "use NODE to set the node"
		    exit 0
		fi
		for device in $DEVICES; do
		    echo "config $NODE $device"
		    run_on_node $NODE "CONFIG=$CONFIG DEVICE=$device ./wlandevice.sh start" "$DIR/../../nodes/bin/" $DIR/../etc/keys/id_dsa
		done
		;;
	*)
		$0 help
		;;
esac

exit 0		
