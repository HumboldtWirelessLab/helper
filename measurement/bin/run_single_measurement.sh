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

. $DIR/../../host/bin/functions.sh

NODELIST=`cat $CONFIGFILE | grep -v "#" | awk '{print $1}' | sort -u`

check_nodes() {

    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh statusmarker`

    if [ ! "x$NODESTATUS" = "xok" ]; then
	echo "Nodestatus: $NODESTATUS"
	echo "WHHHHOOOOO: LOOKS LIKE RESTART! GOD SAVE THE WATCHDOG"
	echo "reboot all nodes"
	NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot

	echo "wait for all nodes"
	sleep 20
	echo "error" 1>&$STATUSFD
	exit 0
    fi
}

get_node_status()  {
    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh statusmarker`
    echo "$NODESTATUS"
}

if [ "x$RUNMODE" = "x" ]; then
    RUNMODE=UNKNOWN
fi

case "$RUNMODE" in
	"REBOOT")
			RUNMODENUM=1
			;;
	"ENVIRONMENT")
			RUNMODENUM=2
			;;
	"DRIVER")
			RUNMODENUM=3
			;;
	"CONFIG")
			RUNMODENUM=4
			;;
	"CLICK")
			RUNMODENUM=5
			;;
	"APPLICATION")
			RUNMODENUM=5
			;;
	*)
			RUNMODENUM=0
			;;
esac				

echo "check all nodes"
NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodes

if [ $RUNMODENUM -eq 0 ]; then
    echo -n "Check marker ($MARKER): "
    CHECKNODESTATUS=`get_node_status`
    echo "$CHECKNODESTATUS"
    if [ ! "x$CHECKNODESTATUS" = "xok" ]; then
	RUNMODENUM=1
    else
	RUNMODENUM=5
    fi
fi

if [ $RUNMODENUM -le 1 ]; then
    echo "reboot all nodes"
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot
     
    echo "wait for all nodes"
    sleep 20
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodes
    sleep 20
fi

if [ $RUNMODENUM -le 2 ]; then
    echo "Setup environment"
    NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh mount
fi

echo "Set marker for reboot-detection"

NODELIST="$NODELIST" MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh setmarker

if [ $RUNMODENUM -le 3 ]; then
    NODELIST="$NODELIST" $DIR/../../host/bin/wlanmodules.sh rmmod

    for node in $NODELIST; do
	MODULSDIR=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $3}' | tail -n 1`
	
	CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $5}' | tail -n 1`
	RECOMMENDMODOPTIONS=`cat $CONFIGFILE | grep RECOMMENDMODOPTIONS | awk -F= '{print $2}'`
	if [ "x$RECOMMENDMODOPTIONS" != "x" ]; then
	    MODOPTIONS=$RECOMMENDMODOPTIONS
	else
	    MODOPTIONS=modoptions.default
	fi	

	NODELIST="$node" MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../host/bin/wlanmodules.sh insmod
    done

    check_nodes
    sleep 1
fi

if [ $RUNMODENUM -le 4 ]; then
    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh create
	done
    done

    check_nodes
    sleep 1

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh start
	done
    done

    check_nodes
    sleep 1

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh config
	done
    done

    check_nodes

fi

if [ $RUNMODENUM -le 5 ]; then

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		echo "Deviceconfig for $node:$nodedevice" 
		NODE=$node DEVICES=$nodedevice $DIR/../../host/bin/wlandevices.sh getiwconfig
	done
    done

    SCREENNAME="measurement_$ID"
    
    screen -d -m -S $SCREENNAME

    NODEBINDIR="$DIR/../../nodes/bin"

############################################
###### Click- & Application-Stuff ##########
############################################

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	
	NODEARCH=`get_arch $node $DIR/../../host/etc/keys/id_dsa`
	
	for nodedevice in $NODEDEVICELIST; do
		CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`

		CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $6}'`
		LOGFILE=`echo "$CONFIGLINE" | awk '{print $7}'`

		if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
			SCREENT="$node\_$nodedevice\_click"	
			screen -S $SCREENNAME -X screen -t $SCREENT
   			sleep 0.1
			screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $DIR/../../host/etc/keys/id_dsa root@$node \"$NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT | $NODEBINDIR/click-$NODEARCH  > $LOGFILE 2>&1\""
		fi

		APPLICATION=`echo "$CONFIGLINE" | awk '{print $8}'`
		APPLOGFILE=`echo "$CONFIGLINE" | awk '{print $9}'`
		
		if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then
			SCREENT="$node\_$nodedevice\_app"	
			screen -S $SCREENNAME -X screen -t $SCREENT
   			sleep 0.1
			screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $DIR/../../host/etc/keys/id_dsa root@$node \"$APPLICATION  > $APPLOGFILE 2>&1\""
		fi
	done
    done

###################################################
####### Start Click- & Application-Stuff ##########
###################################################

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
		CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`

		CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $6}'`
		LOGFILE=`echo "$CONFIGLINE" | awk '{print $7}'`

		if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
			SCREENT="$node\_$nodedevice\_click"	
    			screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'
		fi

		APPLICATION=`echo "$CONFIGLINE" | awk '{print $8}'`
		APPLOGFILE=`echo "$CONFIGLINE" | awk '{print $9}'`

		if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then
			SCREENT="$node\_$nodedevice\_app"	
    			screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'
		fi
	done
    done

###################################################
################# Wait and Stop ###################
###################################################

    WAITTIME=`expr $TIME + 5`
    echo "Wait for $WAITTIME sec"

    echo -n -e "Wait... \033[1G" >&6
    for ((i = $WAITTIME; i > 0; i--)); do echo -n -e "Wait... $i \033[1G" >&6 ; sleep 1; done
    echo -n -e "                 \033[1G" >&6

#   sleep $WAITTIME

    screen -S $SCREENNAME -X quit

    check_nodes
    
    echo "ok" 1>&$STATUSFD
fi

echo "Finished measurement. Status: ok."

exit 0

