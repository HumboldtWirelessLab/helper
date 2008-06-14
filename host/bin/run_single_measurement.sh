#!/bin/bash

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

NODELIST=`cat $CONFIGFILE | grep -v "#" | awk '{print $1}' | sort -u`

check_nodes() {

    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/status.sh statusmarker`

    if [ ! "x$NODESTATUS" = "xok" ]; then
	echo "Nodestatus: $NODESTATUS"
	echo "WHHHHOOOOO: LOOKS LIKE RESTART! GOD SAVE THE WATCHDOG"
	echo "reboot all nodes"
	NODELIST="$NODELIST" $DIR/system.sh reboot

	echo "wait for all nodes"
	sleep 60
	echo "error" 1>&$STATUSFD
	exit 0
    fi
}

echo "check all nodes"
NODELIST="$NODELIST" $DIR/system.sh waitfornodes

echo "reboot all nodes"
NODELIST="$NODELIST" $DIR/system.sh reboot
     
echo "wait for all nodes"
sleep 20
NODELIST="$NODELIST" $DIR/system.sh waitfornodes
sleep 20

echo "Setup environment"
NODELIST="$NODELIST" $DIR/environment.sh mount

NODELIST="$NODELIST" MARKER="/tmp/$MARKER" $DIR/status.sh setmarker

NODELIST="$NODELIST" $DIR/wlanmodules.sh rmmod

for node in $NODELIST; do
	MODULSDIR=`cat $CONFIGFILE | grep "^$node" | awk '{print $3}' | tail -n 1`
	NODELIST="$node" MODULSDIR=$MODULSDIR $DIR/wlanmodules.sh insmod
done

check_nodes
sleep 2

for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | grep "^$node" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CONFIG=`cat $CONFIGFILE | grep "^$node" | grep "$nodedevice" | awk '{print $4}'`
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/wlandevices.sh create
	done
done

check_nodes
sleep 2

for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | grep "^$node" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CONFIG=`cat $CONFIGFILE | grep "^$node" | grep "$nodedevice" | awk '{print $4}'`
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/wlandevices.sh start
	done
done

check_nodes
sleep 2

for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | grep "^$node" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CONFIG=`cat $CONFIGFILE | grep "^$node" | grep "$nodedevice" | awk '{print $4}'`
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/wlandevices.sh config
	done
done

check_nodes

SCREENNAME="measurement_$ID"
    
screen -d -m -S $SCREENNAME
sleep 0.2

NODEBINDIR="$DIR/../../nodes/bin"

for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | grep "^$node" | awk '{print $2}'`
	
	NODEARCH=`get_arch $node $DIR/../../host/etc/keys/id_dsa`
	
	for nodedevice in $NODEDEVICELIST; do
		CLICKSCRIPT=`cat $CONFIGFILE | grep "^$node" | grep "$nodedevice" | awk '{print $5}'`
		LOGFILE=`cat $CONFIGFILE | grep "^$node" | grep "$nodedevice" | awk '{print $6}'`
		
		if [ ! "x$CLICKSCRIPT" = "x" ]; then
		if [ ! "x$CLICKSCRIPT" = "x-" ]; then
			SCREENT="$node\_$nodedevice"	

			screen -S $SCREENNAME -X screen -t $SCREENT
   			sleep 0.2
			screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $DIR/../../host/etc/keys/id_dsa root@$node \"$NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT | $NODEBINDIR/click-$NODEARCH  > $LOGFILE 2>&1\""
			sleep 0.2
		fi
		fi
	done
done

for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | grep "^$node" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CLICKSCRIPT=`cat $CONFIGFILE | grep "^$node" | grep "$nodedevice" | awk '{print $5}'`
		LOGFILE=`cat $CONFIGFILE | grep "^$node" | grep "$nodedevice" | awk '{print $6}'`

		if [ ! "x$CLICKSCRIPT" = "x" ]; then
		if [ ! "x$CLICKSCRIPT" = "x-" ]; then
			SCREENT="$node\_$nodedevice"	
    			screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'
			sleep 1
		fi
		fi
	done
done

echo "Wait for $TIME sec"
sleep $TIME

screen -S $SCREENNAME -X quit

check_nodes

echo "ok" 1>&$STATUSFD
echo "Finished measurement. Status: ok."

exit 0
