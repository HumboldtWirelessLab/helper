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

SCREENFILENAME=screenmap

##############################################
###### Functions to check the nodes ##########
##############################################
#TODO

CURRENTMODE="START"

check_nodes() {

    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh statusmarker`

    if [ ! "x$NODESTATUS" = "xok" ]; then
      echo "Nodestatus: $NODESTATUS"
      echo "WHHHHOOOOO: LOOKS LIKE RESTART! GOD SAVE THE WATCHDOG"
      echo "Current Mode: $CURRENTMODE"
      echo "Nodes: $NODELIST"
#      echo "reboot all nodes"
#      NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot
#      echo "wait for all nodes"
#      sleep 20
#      echo "error" 1>&$STATUSFD
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

#TODO
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

screenname_for_node() {
  RESULT=`cat $2 | grep -e "^$1[[:space:]]" | awk '{print $2}'`
  echo $RESULT
}


run_command_on_node() {

  SCREENNAME=`screenname_for_node $1 $SCREENFILENAME`

  screen -S $SCREENNAME -p $1 -X stuff "NODELIST=$1 $DIR/../../host/bin/run_on_nodes.sh $2"
  sleep 0.3
  screen -S $SCREENNAME -p $1 -X stuff $'\n'

}

run_command_on_screen() {

  SCREENNAME=`screenname_for_node $1 $SCREENFILENAME`

  echo "Debug: $SCREENNAME" >&5
  screen -S $SCREENNAME -p $1 -X stuff "LOGMARKER=$1 $2"
  sleep 0.3
  screen -S $SCREENNAME -p $1 -X stuff $'\n'

}

##############################
###### SYNC - stuff ##########
##############################

wait_for_nodes() {
  NODES=$1
  
  ALL=0

  DEBUGFILE=status/wait_$2
  #DEBUGFILE=/dev/null

  echo "wait for $1" >> $DEBUGFILE
  
  while [ $ALL -eq 0 ]; do
    NO_NODES=0
    STATE_NODES=0;
    OK_NODES=0;
    
    for n in $NODES; do
    
      STATEFILE="status/$n$2"  >> $DEBUGFILE
      
      echo "looking for $STATEFILE" >> $DEBUGFILE
      NO_NODES=`expr $NO_NODES + 1`
      
      if [ -f $STATEFILE ]; then
        STATE_NODES=`expr $STATE_NODES + 1`
        STATE=`cat $STATEFILE | awk '{print $1}'`
        if [ $STATE -eq 0 ]; then
          OK_NODES=`expr $OK_NODES + 1`
        fi
      fi
    done
    
    echo "RESULT: $NO_NODES $OK_NODES" >> $DEBUGFILE
    
    if [ $NO_NODES -eq $STATE_NODES ]; then
      ALL=1;
    fi
    
    sleep 1
  done
  
  if [ $NO_NODES -eq $OK_NODES ]; then
    echo "0"
  else
    echo "1"
  fi

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
### Create screen for all nodes ####
####################################


SCREENNUMBER=1
NODE_IN_SCREEN=1                                                                                                                                                                                                                                                                       
MAX_NODE_PER_SCREEN=30

for node in $NODELIST; do

  if [ $NODE_IN_SCREEN -eq 1 ]; then
    SCREENNAME=nodes_$MARKER\_$SCREENNUMBER
    screen -d -m -S $SCREENNAME      
  fi

  sleep 0.5;
  screen -S $SCREENNAME -X screen -t $node 
  echo "$node $SCREENNAME" >> $SCREENFILENAME

  NODE_IN_SCREEN=`expr $NODE_IN_SCREEN + 1`

  if [ $NODE_IN_SCREEN -gt $MAX_NODE_PER_SCREEN ]; then
    NODE_IN_SCREEN=1
    SCREENNUMBER=`expr $SCREENNUMBER + 1`
  fi

done

sleep 1
#screen -ls

###############################
######### STATUSDIR ###########
###############################

rm -rf 
mkdir status

###############################
##### START PREPARE NODES #####
###############################

echo "Start node setup"
for node in $NODELIST; do
  run_command_on_screen $node "NODELIST=\"$node\" $DIR/prepare_single_node.sh"
done

####################################
###### Wait for all nodes ##########
####################################

####################################################
###### Reboot all nodes and wait for them ##########
####################################################

###################################
###### Setup Environment ##########
###################################

###################################
##### Prestart local process ######
###################################

##################################
###### Load Wifi-Moduls ##########
##################################

############################
###### Setup Wifi ##########
############################

######################################################
###### Get Wifiinfo and Start Screensession ##########
######################################################

###################################
###### Setup Clickmodule ##########
###################################

echo "Wait for nodes"
SYNCSTATE=`wait_for_nodes "$NODELIST" _preload.state`
echo "all nodes ready"

####################################
#### Kill screen for all nodes #####
####################################

SCREENFILENAME=screenmap

SCREENNUMBER=1
NODE_IN_SCREEN=1                                                                                                                                                                                                                                                                       
MAX_NODE_PER_SCREEN=30

for node in $NODELIST; do

  SCREENNAME=nodes_$MARKER\_$SCREENNUMBER

  screen -S $SCREENNAME -p $node -X stuff "exit" > /dev/null 2>&1
  sleep 0.5;
  screen -S $SCREENNAME -p $node -X stuff $'\n' > /dev/null 2>&1

  NODE_IN_SCREEN=`expr $NODE_IN_SCREEN + 1`

  if [ $NODE_IN_SCREEN -gt $MAX_NODE_PER_SCREEN ]; then
    screen -S $SCREENNAME -X quit
    NODE_IN_SCREEN=1
    SCREENNUMBER=`expr $SCREENNUMBER + 1`
  fi

done

if [ $NODE_IN_SCREEN -gt 1 ]; then 
  screen -S $SCREENNAME -X quit
fi

#####################################
###### Start Screensession ##########
#####################################

  SCREENNAME="measurement_$ID"
    
  screen -d -m -S $SCREENNAME

  NODEBINDIR="$DIR/../../nodes/bin"

    
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
			screen -S $SCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"$APPLICATION start > $APPLOGFILE 2>&1\""
		fi
	done
    done

###################################################
####### Start Click- & Application-Stuff ##########
###################################################

    if [ "x$LOCALPROCESS" != "x" ]; then
      echo ""
      echo "Debug: export PATH=$DIR/../../host/bin:$PATH;NODELIST=\"$NODELIST\" $LOCALPROCESS start >> $FINALRESULTDIR/localapp.log 2>&1"
      screen -S $SCREENNAME -X screen -t localprocess
      sleep 0.1
      screen -S $SCREENNAME -p localprocess -X stuff "export PATH=$DIR/../../host/bin:$PATH;RUNTIME=$TIME RESULTDIR=$FINALRESULTDIR NODELIST=\"$NODELIST\" $LOCALPROCESS start >> $FINALRESULTDIR/localapp.log 2>&1"
      sleep 0.5
      screen -S $SCREENNAME -p localprocess -X stuff $'\n'
    fi

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

  if [ "x$LOCALPROCESS" != "x" ]; then
#    CPWD=`pwd`
#    echo ""
#    echo "Debug: export PATH=$DIR/../../host/bin:$PATH;NODELIST=\"$NODELIST\" $LOCALPROCESS stop >> $FINALRESULTDIR/localapp.log 2>&1"
#    screen -S $SCREENNAME -p localprocess -X stuff "export PATH=$DIR/../../host/bin:$PATH;NODELIST=\"$NODELIST\" $LOCALPROCESS stop >> $FINALRESULTDIR/localapp.log 2>&1"
#    sleep 0.1
#    screen -S $SCREENNAME -p localprocess -X stuff $'\n'
    PATH=$DIR/../../host/bin:$PATH;NODELIST=\"$NODELIST\" $LOCALPROCESS stop >> $FINALRESULTDIR/localapp.log 2>&1
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

#######################################
##### Poststop local process ##########
#######################################

if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
  echo "Stop local process"
  $LOCALPROCESS poststop >> $FINALRESULTDIR/localapp.log
fi

echo "Finished measurement. Status: ok."

exit 0