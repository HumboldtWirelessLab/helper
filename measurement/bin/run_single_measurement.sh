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

####################################
###### Wait for all nodes ##########
####################################

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

##################################
###### Reboot all nodes ##########
##################################

if [ $RUNMODENUM -le 1 ]; then
    echo "reboot all nodes"
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot
     
    echo "wait for all nodes"
    sleep 20
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodes
    sleep 20
fi

###################################
###### Setup Environment ##########
###################################


if [ $RUNMODENUM -le 2 ]; then
    echo "Setup environment"
    NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh mount
fi

echo "Set marker for reboot-detection"

NODELIST="$NODELIST" MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh setmarker

##################################
###### Load Wifi-Moduls ##########
##################################

if [ $RUNMODENUM -le 3 ]; then

    echo "Load Moduls"

    NODELIST="$NODELIST" $DIR/../../host/bin/wlanmodules.sh rmmod

    for node in $NODELIST; do

	MODULSDIR=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $3}' | tail -n 1`
	MODOPTIONS=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $4}' | tail -n 1`
	CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $5}' | tail -n 1`

	if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
	    if [ "x$MODOPTIONS" = "x" ] || [ "x$MODOPTIONS" = "x-" ]; then
		RECOMMENDMODOPTIONS=`cat $CONFIG | grep RECOMMENDMODOPTIONS | awk -F= '{print $2}'`
		if [ "x$RECOMMENDMODOPTIONS" != "x" ]; then
		    MODOPTIONS=$RECOMMENDMODOPTIONS
		else
		    MODOPTIONS=modoptions.default
		fi
	    fi	

	    NODELIST="$node" MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../host/bin/wlanmodules.sh insmod
	fi
    done

    check_nodes
    sleep 1
fi

############################
###### Setup Wifi ##########
############################

if [ $RUNMODENUM -le 4 ]; then

    echo "Setup Wifi"

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh create
	    fi
	done
    done

    check_nodes
    sleep 1

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
    		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh start
	    fi
	done
    done

    check_nodes
    sleep 1

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh config
	    fi
	done
    done

    check_nodes

fi

######################################################
###### Get Wifiinfo and Start Screensession ##########
######################################################

if [ $RUNMODENUM -le 5 ]; then

    echo "Get Wifiinfo"

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    echo "Deviceconfig for $node:$nodedevice" 
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		NODE=$node DEVICES=$nodedevice $DIR/../../host/bin/wlandevices.sh getiwconfig
	    fi
	done
    done

    SCREENNAME="measurement_$ID"
    
    screen -d -m -S $SCREENNAME

    NODEBINDIR="$DIR/../../nodes/bin"

###################################
###### Setup Clickmodule ##########
###################################

    for node in $NODELIST; do

	CLICKMODDIR=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $6}' | tail -n 1`

	if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
	    NODELIST="$node" MODULSDIR=$CLICKMODDIR $DIR/../../host/bin/click.sh reloadmod
	fi
    done

    check_nodes

########################################################
###### Setup Click-, Log- & Application-Stuff ##########
########################################################

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	
	NODEARCH=`get_arch $node $DIR/../../host/etc/keys/id_dsa`
	
	for nodedevice in $NODEDEVICELIST; do
		CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`

		CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
		CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
		LOGFILE=`echo "$CONFIGLINE" | awk '{print $8}'`

		if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
			SCREENT="$node\_$nodedevice\_click"	
			screen -S $SCREENNAME -X screen -t $SCREENT
   			sleep 0.1
			
			if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
			    CLICKWAITTIME=`expr $TIME + 2`
			    screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $DIR/../../host/etc/keys/id_dsa root@$node \"$NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT > /tmp/click/config; sleep $CLICKWAITTIME; echo -n > /tmp/click/config\""

 			    sleep 0.1
			    SCREENT="$node\_$nodedevice\_kcm"	
			    screen -S $SCREENNAME -X screen -t $SCREENT
  			    sleep 0.1
			    screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $DIR/../../host/etc/keys/id_dsa root@$node \"rm -f $LOGFILE ; cat /proc/kmsg >> $LOGFILE \""
			else
			    screen -S $SCREENNAME -p $SCREENT -X stuff "ssh -i $DIR/../../host/etc/keys/id_dsa root@$node \"$NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT | $NODEBINDIR/click-$NODEARCH  > $LOGFILE 2>&1\""
			fi
		fi

		APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`
		APPLOGFILE=`echo "$CONFIGLINE" | awk '{print $10}'`
		
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

		CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`

		if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
			SCREENT="$node\_$nodedevice\_click"
    			screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'

			CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
			if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
			    SCREENT="$node\_$nodedevice\_kcm"
			    screen -S $SCREENNAME -p $SCREENT -X stuff $'\n'
			fi
		fi

		APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`

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

# Countdown
    echo -n -e "Wait... \033[1G" >&6
    for ((i = $WAITTIME; i > 0; i--)); do echo -n -e "Wait... $i \033[1G" >&6 ; sleep 1; done
    echo -n -e "                 \033[1G" >&6

#Normal wait
#   sleep $WAITTIME

###################################################
##### Kill progs for logfile for kclick  ##########
###################################################
    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	
	for nodedevice in $NODEDEVICELIST; do
		CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`
		CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
		CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
		if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ] && [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
			    TAILPID=`ssh -i $DIR/../../host/etc/keys/id_dsa root@$node "pidof cat"`
			    ssh -i $DIR/../../host/etc/keys/id_dsa root@$node "kill $TAILPID"
		fi
	done
    done

    screen -S $SCREENNAME -X quit

    check_nodes
    
    echo "ok" 1>&$STATUSFD
fi

echo "Finished measurement. Status: ok."

exit 0
