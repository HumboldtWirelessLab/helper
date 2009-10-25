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
	echo "Nodes: $NODELIST"
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

#########################################################
############ Clean up after abort #######################
#########################################################

trap abort_measurement 1 2 3 6

abort_measurement() {
	
    echo "Abort Measurement" >&6
	
    if [ $RUN_CLICK_APPLICATION -eq 1 ]; then

	for node in $NODELIST; do
	    NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	
	    for nodedevice in $NODEDEVICELIST; do
		CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`
		CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
		CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
		if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ] && [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
			    TAILPID=`run_on_node $node "pidof cat" "/" $DIR/../../host/etc/keys/id_dsa`
			    run_on_node $node "kill $TAILPID" "/" $DIR/../../host/etc/keys/id_dsa
		else
		    if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
				NODEARCH=`get_arch $node $DIR/../../host/etc/keys/id_dsa`
				CLICKPID=`run_on_node $node "pidof click-$NODEARCH" "/" $DIR/../../host/etc/keys/id_dsa`
				if [ "x$CLICKPID" != "x" ]; then
					for cpid in $CLICKPID; do
						run_on_node $node "kill $cpid" "/" $DIR/../../host/etc/keys/id_dsa
					done
				fi
		    fi
		fi
		
		APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`
		
        if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then
			run_on_node $node "$APPLICATION  stop" "/" $DIR/../../host/etc/keys/id_dsa
        fi

	    done
	done
    fi

    screen -S $SCREENNAME -X quit

    if [ $RUN_CLICK_APPLICATION -eq 1 ]; then
        check_nodes
    fi
    
    echo "abort" 1>&$STATUSFD

    echo "Finished measurement. Status: abort."

    exit 0
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

####################################################
###### Reboot all nodes and wait for them ##########
####################################################

if [ $RUNMODENUM -le 1 ]; then
    echo "Reboot all nodes"
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot
     
    echo "Wait for all nodes"
    sleep 30
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodesandssh
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

    echo "Load Modules"
    CURRENTMODE="LOAD MODULES"
    LOADMODULES=0

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
	    LOADMODULES=1
	fi
    done

    if [ $LOADMODULES -eq 1 ]; then
	#check nodes and sleep, only if modules are need to load
	check_nodes
	sleep 1
    fi
fi

############################
###### Setup Wifi ##########
############################

if [ $RUNMODENUM -le 4 ]; then

    echo "Setup Wifi"
    CURRENTMODE="CREATE WIFI"
    CREATEWIFI=0
    
    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh create
		CREATEWIFI=1
	    fi
	done
    done

    if [ $CREATEWIFI -eq 1 ]; then
	#check nodes and sleep if device should be created
	check_nodes
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
    		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh start
	        STARTWIFI=1
	    fi
	done
    done

    if [ $STARTWIFI -eq 1 ]; then
        check_nodes
	sleep 1
    fi
    
    CURRENTMODE="CONFIG WIFI"
    CONFIGWIFI=0

    for node in $NODELIST; do
	NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh config
		CONFIGWIFI=1
	    fi
	done
    done

    if [ $CONFIGWIFI -eq 1 ]; then
        check_nodes
    fi
    
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

    CURRENTMODE="LOAD CLICKMOD"
    LOADCLICKMOD=0

    for node in $NODELIST; do

	CLICKMODDIR=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $6}' | tail -n 1`

	if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
	    NODELIST="$node" MODULSDIR=$CLICKMODDIR $DIR/../../host/bin/click.sh reloadmod
	    LOADCLICKMOD=1
	fi
    done

    if [ $LOADCLICKMOD -eq 1 ]; then
	check_nodes
    fi

########################################################
###### Preload Click-, Log- & Application-Stuff ########
########################################################
#TODO:
#just load everything once to have it in the cache like: cat click > /dev/null on each maschine
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
	    echo "Application preload on $node"
    	    run_on_node $node "cat $APPLICATION > /dev/null" "/" $DIR/../../host/etc/keys/id_dsa
	fi
      done
      
      if [ "x$LOADCLICK" = "x1" ]; then
	echo "Click preload on $node"
        run_on_node $node "export CLICKPATH=$NODEBINDIR/../etc/click;echo \"Script(wait 0,stop);\" | $NODEBINDIR/click-align-$NODEARCH | $NODEBINDIR/click-$NODEARCH" "/" $DIR/../../host/etc/keys/id_dsa
      fi
    done

    
########################################################
###### Setup Click-, Log- & Application-Stuff ##########
########################################################

    CURRENTMODE="RUN CLICK AND APPLICATION"
    RUN_CLICK_APPLICATION=0

    for node in $NODELIST; do
      NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	
      NODEARCH=`get_arch $node $DIR/../../host/etc/keys/id_dsa`
	
      for nodedevice in $NODEDEVICELIST; do
        CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`

        CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
        CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
        LOGFILE=`echo "$CONFIGLINE" | awk '{print $8}'`

        if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
			
        RUN_CLICK_APPLICATION=1
			
        SCREENT="$node\_$nodedevice\_click"	
        screen -S $SCREENNAME -X screen -t $SCREENT
   			sleep 0.1
			
			if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
			    CLICKWAITTIME=`expr $TIME + 2`
			    screen -S $SCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"export CLICKPATH=$NODEBINDIR/../etc/click;$NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT > /tmp/click/config; sleep $CLICKWAITTIME; echo -n > /tmp/click/config\""

 			    sleep 0.1
			    SCREENT="$node\_$nodedevice\_kcm"	
			    screen -S $SCREENNAME -X screen -t $SCREENT
			    sleep 0.1
			    screen -S $SCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"rm -f $LOGFILE; cat /proc/kmsg >> $LOGFILE \""
			else
			    screen -S $SCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"export CLICKPATH=$NODEBINDIR/../etc/click;$NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT | $NODEBINDIR/click-$NODEARCH  > $LOGFILE 2>&1\""
			fi
		fi

		APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`
		APPLOGFILE=`echo "$CONFIGLINE" | awk '{print $10}'`
		
		if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then

			RUN_CLICK_APPLICATION=1

			SCREENT="$node\_$nodedevice\_app"	
			screen -S $SCREENNAME -X screen -t $SCREENT
   			sleep 0.1
			screen -S $SCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"export PATH=$DIR/../../host/bin:$PATH;NODELIST=\"$NODELIST\" $APPLICATION start > $APPLOGFILE 2>&1\""
		fi
	done
    done

###################################################
####### Start Click- & Application-Stuff ##########
###################################################

    if [ $RUN_CLICK_APPLICATION -eq 1 ]; then

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
    fi

###################################################
################# Wait and Stop ###################
###################################################

    if [ $RUN_CLICK_APPLICATION -eq 1 ]; then

	#add 5 second extra to make sure that we are not faster than the devices (click,application)
	WAITTIME=`expr $TIME + 5`
	echo "Wait for $WAITTIME sec"

	# Countdown
	echo -n -e "Wait... \033[1G" >&6
	for ((i = $WAITTIME; i > 0; i--)); do echo -n -e "Wait... $i \033[1G" >&6 ; sleep 1; done
	echo -n -e "                 \033[1G" >&6

	#Normal wait
	#sleep $WAITTIME

    fi

###################################################
##### Kill progs for logfile for kclick  ##########
###################################################

    if [ $RUN_CLICK_APPLICATION -eq 1 ]; then

	echo "Kill Click on Nodes:"
	for node in $NODELIST; do
	    NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	
	    for nodedevice in $NODEDEVICELIST; do
	    	echo -n "$node"

		CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`
		CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
		CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
		if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ] && [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
			    TAILPID=`run_on_node $node "pidof cat" "/" $DIR/../../host/etc/keys/id_dsa`
			    run_on_node $node "kill $TAILPID" "/" $DIR/../../host/etc/keys/id_dsa
		else
		    if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
				NODEARCH=`get_arch $node $DIR/../../host/etc/keys/id_dsa`
				CLICKPID=`run_on_node $node "pidof click-$NODEARCH" "/" $DIR/../../host/etc/keys/id_dsa`
				if [ "x$CLICKPID" != "x" ]; then
					for cpid in $CLICKPID; do
						echo -n "PID: $CLICKPID !"
						run_on_node $node "kill $cpid" "/" $DIR/../../host/etc/keys/id_dsa
					done
				fi
		    fi
		fi
		
		APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`
		
                if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then
			run_on_node $node "$APPLICATION  stop" "/" $DIR/../../host/etc/keys/id_dsa
                fi
		echo " done"
	    done
	done
    fi

#####################################
##### Close Screen-Session ##########
#####################################

    screen -S $SCREENNAME -X quit

#######################################
##### Check Nodes and finish ##########
#######################################

    echo "Check nodes"
    if [ $RUN_CLICK_APPLICATION -eq 1 ]; then
        check_nodes
    fi
    
    echo "ok" 1>&$STATUSFD

fi

echo "Finished measurement. Status: ok."

exit 0
