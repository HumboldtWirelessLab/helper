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

RUN_CLICK_APPLICATION=0

##############################################
###### Functions to check the nodes ##########
##############################################

CURRENTMODE="START"

check_nodes() {

    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh statusmarker`

    if [ ! "x$NODESTATUS" = "xok" ]; then
	    echo "Nodestatus: $NODESTATUS"
	    echo "WHHHHOOOOO: LOOKS LIKE RESTART! GOD SAVE THE WATCHDOG"
      echo "Current Mode: $CURRENTMODE"
	    echo "Node: $NODELIST"
	    echo "reboot the node"
	    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot

	    echo "wait for all nodes"
	    sleep 20
	    echo "error" > status/$NODELIST.log
	    
	    echo "1" > $1
	    
	    exit 0
    fi
}

get_node_status()  {
    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh statusmarker`
    echo "$NODESTATUS"
}

#########################################################
###### Check RUNMODE. What do you want to do ? ##########
#########################################################

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

LOGMARKER=$NODELIST

echo "$NODELIST" > status/$LOGMARKER\_reboot.log

echo "check node $NODELIST" >> status/$LOGMARKER\_reboot.log
NODELIST="$NODELIST" $DIR/.././host/bin/system.sh waitfornodes >> status/$LOGMARKER\_reboot.log

if [ $RUNMODENUM -eq 0 ]; then
    echo -n "Check marker ($MARKER): " >> status/$LOGMARKER\_reboot.log
    CHECKNODESTATUS=`get_node_status`
    echo "$CHECKNODESTATUS" >> status/$LOGMARKER\_reboot.log
    if [ ! "x$CHECKNODESTATUS" = "xok" ]; then
	    RUNMODENUM=1
    else
	    RUNMODENUM=5
    fi
fi

####################################################
###### Reboot all nodes and wait for them ##########
####################################################

if [ $RUNMODENUM -le 1 ]; then
    echo "Reboot node $NODELIST" >> status/$LOGMARKER\_reboot.log
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot >> status/$LOGMARKER\_reboot.log
     
    echo "Wait for node $NODELIST" >> status/$LOGMARKER\_reboot.log
    sleep 30
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodesandssh >> status/$LOGMARKER\_reboot.log
fi

echo "0" > status/$LOGMARKER\_reboot.state

###################################
###### Setup Environment ##########
###################################

if [ $RUNMODENUM -le 2 ]; then
    echo "Setup environment $NODELIST" > status/$LOGMARKER\_environment.log
    NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh mount >> status/$LOGMARKER\_environment.log
fi

echo "Set marker for reboot-detection $NODELIST" >> status/$LOGMARKER\_environment.log

NODELIST="$NODELIST" MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh setmarker >> status/$LOGMARKER\_environment.log

echo "0" > status/$LOGMARKER\_environment.state

##################################
###### Load Wifi-Moduls ##########
##################################

if [ $RUNMODENUM -le 3 ]; then

    echo "Load Modules" > status/$LOGMARKER\_wifimodules.log
    CURRENTMODE="LOAD MODULES"
    LOADMODULES=0

    NODELIST="$NODELIST" $DIR/../../host/bin/wlanmodules.sh rmmod >> status/$LOGMARKER\_wifimodules.log

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

          NODELIST="$node" MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../host/bin/wlanmodules.sh insmod >> status/$LOGMARKER\_wifimodules.log
          LOADMODULES=1
      fi
    done

    if [ $LOADMODULES -eq 1 ]; then
	    #check nodes and sleep, only if modules are need to load
	    check_nodes status/$LOGMARKER\_wifimodules.state >> status/$LOGMARKER\_wifimodules.log
	    sleep 1
    fi
fi

echo "0" > status/$LOGMARKER\_wifimodules.state

############################
###### Setup Wifi ##########
############################

if [ $RUNMODENUM -le 4 ]; then

  echo "Setup Wifi" > status/$LOGMARKER\_wificonfig.log
  CURRENTMODE="CREATE WIFI"
  CREATEWIFI=0
    
  for node in $NODELIST; do
	  NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	  for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		    NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh create >> status/$LOGMARKER\_wificonfig.log
		    CREATEWIFI=1
	    fi
	  done
  done

  if [ $CREATEWIFI -eq 1 ]; then
    #check nodes and sleep if device should be created
	  check_nodes status/$LOGMARKER\_wificonfig.state >> status/$LOGMARKER\_wificonfig.log
	  sleep 1
	  #extra sleep for WGTs
	  sleep 2
  fi

  CURRENTMODE="START WIFI"
  STARTWIFI=0

  for node in $NODELIST; do
	  NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
    for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
    		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh start >> status/$LOGMARKER\_wificonfig.log
	        STARTWIFI=1
	    fi
	  done
  done

  if [ $STARTWIFI -eq 1 ]; then
    check_nodes status/$LOGMARKER\_wificonfig.state >> status/$LOGMARKER\_wificonfig.log
	  sleep 1
  fi
    
  CURRENTMODE="CONFIG WIFI"
  CONFIGWIFI=0

  for node in $NODELIST; do
	  NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	  for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		    NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh config >> status/$LOGMARKER\_wificonfig.log
		    CONFIGWIFI=1
	    fi
	  done
  done

  if [ $CONFIGWIFI -eq 1 ]; then
    check_nodes status/$LOGMARKER\_wificonfig.state >> status/$LOGMARKER\_wificonfig.log
  fi
    
  echo "0" > status/$LOGMARKER\_wificonfig.state

fi

##############################
###### Get Wifiinfo ##########
##############################
#TODO: rename nodelist

if [ $RUNMODENUM -le 5 ]; then

  echo "Get Wifiinfo" >> status/$LOGMARKER\_wifiinfo.log

  for node in $NODELIST; do
    NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
    for nodedevice in $NODEDEVICELIST; do
      CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    echo "Deviceconfig for $node:$nodedevice" >> status/$LOGMARKER\_wifiinfo.log
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
        NODE=$node DEVICES=$nodedevice $DIR/../../host/bin/wlandevices.sh getiwconfig >> status/$LOGMARKER\_wifiinfo.log
	    fi
	    
	    if [ "x$WANTNODELIST" = "xyes" ]; then
	      MADDR=`run_on_node $node "DEVICE=$nodedevice $DIR/../../nodes/bin/wlandevice.sh getmac" "/" $DIR/../../host/etc/keys/id_dsa`
	      echo "$node $nodedevice $MADDR" >> $FINALRESULTDIR/nodelist_$NODELIST
	    fi
	    
	  done
  done

  echo "0" > status/$LOGMARKER\_wifiinfo.state

fi

###################################
###### Setup Clickmodule ##########
###################################

  CURRENTMODE="LOAD CLICKMOD" > status/$LOGMARKER\_clickmodule.log
  LOADCLICKMOD=0

  for node in $NODELIST; do

	  CLICKMODDIR=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $6}' | tail -n 1`

	  if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
	    NODELIST="$node" MODULSDIR=$CLICKMODDIR $DIR/../../host/bin/click.sh reloadmod >> status/$LOGMARKER\_clickmodule.log
	    LOADCLICKMOD=1
	  fi
  done

  if [ $LOADCLICKMOD -eq 1 ]; then
	  check_nodes status/$LOGMARKER\_clickmodule.state >> status/$LOGMARKER\_clickmodule.log
  fi

  echo "0" > status/$LOGMARKER\_clickmodule.state
  
########################################################
###### Preload Click-, Log- & Application-Stuff ########
########################################################

  for node in $NODELIST; do
    NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
    NODEARCH=`get_arch $node $DIR/../../host/etc/keys/id_dsa`
	
    LOADCLICK=0
    for nodedevice in $NODEDEVICELIST; do
      CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`

      CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
      CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
      LOGFILE=`echo "$CONFIGLINE" | awk '{print $8}'`

      if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
	      LOADCLICK=1
    	fi

	    APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`
	    APPLOGFILE=`echo "$CONFIGLINE" | awk '{print $10}'`
		
	    if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then
	      echo "Application preload on $node" >> status/$LOGMARKER\_preload.log
        run_on_node $node "cat $APPLICATION > /dev/null" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_preload.log
	    fi
    done
      
    if [ "x$LOADCLICK" = "x1" ]; then
	    echo "Click preload on $node" >> status/$LOGMARKER\_preload.log
      run_on_node $node "export CLICKPATH=$NODEBINDIR/../etc/click;echo \"Script(wait 0,stop);\" | $NODEBINDIR/click-align-$NODEARCH | $NODEBINDIR/click-$NODEARCH" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_preload.log
    fi
  done

  echo "0" > status/$LOGMARKER\_preload.state

exit 0
