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

NODELIST=`cat $CONFIGFILE | grep -v "#" | awk '{print $1}' | uniq`

RUN_CLICK_APPLICATION=0
CURRENTMODE="START"
MEASUREMENT_ABORT=0

MEASUREMENT_ID=$ID\_$RANDOM

NODESCREENFILENAME=nodescreenmap
MSCREENFILENAME=measurementscreenmap

##############################
###### SYNC - stuff ##########
##############################

wait_for_nodes() {
  NODES=$1

  ALL=0

  #DEBUGFILE=status/wait_$2
  DEBUGFILE=/dev/null

  echo "wait for $1" >> $DEBUGFILE

  FORCE_ABORT=0
  ROUND=0

  while [ $ALL -eq 0 ] && [ $FORCE_ABORT -eq 0 ]; do
    NO_NODES=0
    STATE_NODES=0;
    OK_NODES=0;

    for n in $NODES; do

      STATEFILE="status/$n$2"

      echo "looking for $STATEFILE" >> $DEBUGFILE
      NO_NODES=`expr $NO_NODES + 1`

      if [ -f $STATEFILE ]; then
        echo "  OK" >> $DEBUGFILE
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

    if [ "x$3" != "x" ]; then
      ROUND=`expr $ROUND + 1`
      if [ $ROUND -gt $3 ]; then
        FORCE_ABORT=1
        echo "Stop waiting....!" >&6
      fi
    fi

    if [ $FORCE_ABORT -eq 0 ]; then
      sleep 1
    fi

  done

  if [ $NO_NODES -eq $OK_NODES ]; then
    echo "0"
  else
    echo "1"
  fi

}

get_nodes_ok() {
  NODES=$1

  OK_NODES=""

  for n in $NODES; do

    STATEFILE="status/$n$2"

    if [ -f $STATEFILE ]; then
      NSTATE=`cat $STATEFILE | awk '{print $1}'`
      if [ "x$NSTATE" = "x0" ]; then
        OK_NODES="$OK_NODES $n"
      fi
    fi
  done

  echo "$OK_NODES"
}

set_master_state() {
  echo "$1" >  status/master_$2.state
}

######################################################
############ Finish measurement ######################
######################################################

kill_prog_and_logfiles() {

 set_master_state 0 measurement

  echo -n "State: killclick ... " >&6

  echo "Wait for nodes"
  SYNCSTATE=`wait_for_nodes "$NODELIST" _killclick.state`
  echo "all nodes ready"

  if [ "x$LOCALPROCESS" != "x" ]; then
    PATH=$DIR/../../host/bin:$PATH;RESULTDIR=$FINALRESULTDIR NODELIST=\"$NODELIST\" $LOCALPROCESS stop >> $FINALRESULTDIR/localapp.log 2>&1
  fi

  echo "done." >&6
}

check_nodes() {

  set_master_state 0 killmeasurement

  echo -n "State: Check nodes ... " >&6

  echo "Wait for nodes"
  SYNCSTATE=`wait_for_nodes "$NODELIST" _finalnodecheck.state`
  echo "all nodes ready"

  echo "done." >&6

  echo "ok" 1>&$STATUSFD
}

close_measurement_screen() {

  echo -n "State: Close screen sessions (measurement) ... " >&6

  if [ "x$LOCALPROCESS" != "x" ] || [ "x$REMOTEDUMP" = "xyes" ]; then
    screen -S $LOCALSCREENNAME -X quit
  fi

  MSCREENNAMES=`cat $MSCREENFILENAME | awk '{print $3}' | uniq`
  for MEASUREMENTSCREENNAME in $MSCREENNAMES; do
    screen -S $MEASUREMENTSCREENNAME -X quit
  done

  echo "done." >&6
}

close_node_screen() {

SCREENNUMBER=1
NODE_IN_SCREEN=1
MAX_NODE_PER_SCREEN=30

echo -n "State: Close screen sessions (node ctrl) ... " >&6

for node in $NODELIST; do

  SCREENNAME=nodes_$MEASUREMENT_ID\_$SCREENNUMBER

  screen -S $SCREENNAME -p $node -X stuff "exit" > /dev/null 2>&1
  sleep 0.2;
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

echo "done." >&6

}

######################################################
############ Abort measurement #######################
######################################################

trap abort_measurement 1 2 3 6 15

#TODO
abort_measurement() {

  echo "" >&6
  echo "Abort Measurement" >&6

  if [ $RUN_CLICK_APPLICATION -eq 1 ]; then
    echo "0" > status/master_click_abort.state
  fi

  echo "0" > status/master_abort.state

  MEASUREMENT_ABORT=1

  NODECTRL_CNT=0
  NEW_NODELIST=""

  for p in `ls status/*nodectrl.pid`; do
    NCTRL_PID=`cat $p`
    kill $NCTRL_PID >> status/killnodectrl.log
    echo "kill $NCTRL_PID" >> status/killnodectrl.log
    CURRENT_NODE=`echo $p | sed "s#status/##g" | sed "s#_nodectrl.pid##g"`
    NEW_NODELIST="$NEW_NODELIST $CURRENT_NODE"
    NODECTRL_CNT=`expr $NODECTRL_CNT + 1`
  done

  echo "New nodelist: $NEW_NODELIST" >> status/master_abort.log

  sleep 2

  OLD_NODELIST=$NODELIST
  NODELIST=$NEW_NODELIST

  kill_prog_and_logfiles
  check_nodes

  NODELIST=$OLD_NODELIST

  close_measurement_screen
  close_node_screen

  if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
    echo "Stop local process"
    RESULTDIR=$FINALRESULTDIR $LOCALPROCESS poststop >> $FINALRESULTDIR/localapp.log
  fi

  echo "1" > status/measurement_result.state
  
  exit 0

}

#########################################################
###### Check RUNMODE. What do you want to do ? ##########
#########################################################

screenname_for_node() {
  RESULT=`cat $2 | grep -e "^$1[[:space:]]" | awk '{print $2}'`
  echo $RESULT
}

run_command_for_node() {

  SCREENNAME=`screenname_for_node $1 $NODESCREENFILENAME`

  #echo "Debug: $SCREENNAME" >&5
  screen -S $SCREENNAME -p $1 -X stuff "LOGMARKER=$1 $2"
  sleep 0.1
  screen -S $SCREENNAME -p $1 -X stuff $'\n'

}

#########################################################
###### Check RUNMODE. What do you want to do ? ##########
#########################################################

if [ "x$RUNMODE" = "x" ]; then
    RUNMODE=UNKNOWN
fi

###############################
######### STATUSDIR ###########
###############################

rm -rf status
mkdir status

#####################
### master stuff ####
#####################

echo $$ > status/master.pid

####################################
### Create screen for all nodes ####
####################################

echo -n "Start screen session to setup all nodes ... " >&6

SCREENNUMBER=1
NODE_IN_SCREEN=1
MAX_NODE_PER_SCREEN=30

for node in $NODELIST; do

  if [ $NODE_IN_SCREEN -eq 1 ]; then
    SCREENNAME=nodes_$MEASUREMENT_ID\_$SCREENNUMBER
    screen -d -m -S $SCREENNAME
    sleep 0.3
  fi

  #sleep 0.1;
  screen -S $SCREENNAME -X screen -t $node
  echo "$node $SCREENNAME" >> $NODESCREENFILENAME

  NODE_IN_SCREEN=`expr $NODE_IN_SCREEN + 1`

  if [ $NODE_IN_SCREEN -gt $MAX_NODE_PER_SCREEN ]; then
    NODE_IN_SCREEN=1
    SCREENNUMBER=`expr $SCREENNUMBER + 1`
  fi

done

echo "done." >&6

###############################
##### START PREPARE NODES #####
###############################

echo "Start node setup"
for node in $NODELIST; do
  run_command_for_node $node "MARKER=$ID FINALRESULTDIR=$FINALRESULTDIR RUNMODE=$RUNMODE NODELIST=\"$node\" DISABLE_WIRELESS_BACKBONE=$DISABLE_WIRELESS_BACKBONE $DIR/prepare_single_node.sh"
done

#### STATES ####
#reboot
#environment
#wifimodules
#wificonfig
#wifiinfo
#clickmodule
#preload
#measurement
#killclick
#killmeasurement
#finalnodecheck
####################################
###### Wait for all nodes ##########
####################################

STATES="nodeinfo reboot environment wifimodules wificonfig wifiinfo clickmodule preload"

for state in  $STATES; do
  echo -n "State: $state ... " >&6

  SYNCSTATE=`wait_for_nodes "$NODELIST" _$state.state`
  set_master_state 0 $state

  NODES_OK=`get_nodes_ok "$NODELIST" _$state.state`
  COUNT_NODES_ALL=`echo $NODELIST | wc -w`
  COUNT_NODES_OK=`echo $NODES_OK | wc -w`
  echo "done. Nodes: $COUNT_NODES_OK of $COUNT_NODES_ALL." >&6

  ##################################################
  ########### REMOTE ###############################
  #nodeinfostate: this includes setup wireless nodes

  if [ "x$state" = "xnodeinfo" ]; then
    echo -n "" > status/all_wireless_nodeinfo.log.tmp
    echo -n "" > status/all_wireless_nodes.log
    echo -n "" > status/all_nodeinfo.log
    for node in $NODELIST; do
      if [ -f status/$node\_nodeinfo.log ]; then
        cat status/$node\_nodeinfo.log  >> status/all_nodeinfo.log
      fi
      if [ -f status/$node\_wifinodeinfo.log ]; then
        cat status/$node\_wifinodeinfo.log | awk '{print $2" "$3}' >> status/all_wireless_nodeinfo.log.tmp
      fi
      cat status/$node\_wifinodeinfo.log >> status/all_wireless_nodes.log
    done
    cat status/all_wireless_nodeinfo.log.tmp | sort -u > status/all_wireless_nodeinfo.log

    #rebuild click config if needed (e.g. devicetype,...)
    RESULTDIR=$FINALRESULTDIR $DIR/prepare_measurement.sh afterwards

    #REPLACE DEVICE TMPL
    #TODO: enable multidevice clickscripts
    REWRITER=yes

    if [ "x$REWRITER" = "xyes" ]; then
    echo -n "" > $CONFIGFILE.tmp

    while read line; do
      NODE=`echo $line | awk '{print $1}'`
      KERNEL=`cat status/all_nodeinfo.log | grep "$NODE[[:space:]]" | awk '{print $3}'`
      ARCH=`cat status/all_nodeinfo.log | grep "$NODE[[:space:]]" | awk '{print $2}'`
      DEVNAME=`echo $line | awk '{print $2}'`
      MODULSPATH=`echo $line | awk '{print $3}' | sed -e "s#NODEARCH#$ARCH#g" -e "s#KERNELVERSION#$KERNEL#g"`
      IS_TMPL=`echo $DEVNAME | grep "DEV" | wc -l`

      CLICKFILE=`echo $line | awk '{print $7}'`

      #echo "$NODE $KERNEL $ARCH $DEVNAME $MODULSPATH $IS_TMPL" >> $CONFIGFILE.log
      if [ $IS_TMPL -eq 1 ]; then
        FINALDEVICE=`DEVICE=$DEVNAME MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSPATH $DIR/../../nodes/bin/wlanmodules.sh device_name`
        echo $line | sed -e "s#$DEVNAME#$FINALDEVICE#g" >> $CONFIGFILE.tmp

        CLICKFILE_USE_TMPL=`echo $CLICKFILE | grep $DEVNAME | wc -l`

        if [ $CLICKFILE_USE_TMPL -eq 1 ]; then
          NEW_CLICKFILE=`echo $CLICKFILE | sed -e "s#$DEVNAME#$FINALDEVICE#g"`
          cat $CLICKFILE | sed -e "s#$DEVNAME#$FINALDEVICE#g" > $NEW_CLICKFILE
          rm $CLICKFILE
        fi
      else
        echo $line >> $CONFIGFILE.tmp
      fi

    done < $CONFIGFILE

    mv $CONFIGFILE.tmp $CONFIGFILE

    fi
    #end REPLACE DEVICE TMPL


    REMOTENODECOUNT=`cat status/all_wireless_nodes.log | grep -v "^$" | wc -l`
    if [ $REMOTENODECOUNT -gt 0 ]; then
      WIRELESSNODELIST=`cat status/all_wireless_nodes.log | awk '{print $1}'`
      echo "Found $REMOTENODECOUNT wireless nodes." >&6
      echo "Found $REMOTENODECOUNT wireless nodes: $WIRELESSNODELIST"
      echo "Pack files for wireless nodes." >&6
      $DIR/../lib/remote/pack_files.sh pack status/all_wireless_nodeinfo.log status/all_wireless_nodes.log $CONFIGFILE $FINALRESULTDIR/$DISCRIPTIONFILENAME
      echo "finished pack. Set state to continue node setup"

      echo -n "Unpack files on wireless nodes ... " >&6
      set_master_state 0 wirelesspackage
      SYNCSTATE=`wait_for_nodes "$WIRELESSNODELIST" _wirelesspackage.state`
      echo "done." >&6

      echo -n "Start wireless nodes ... " >&6
      set_master_state 0 wirelessstart
      SYNCSTATE=`wait_for_nodes "$WIRELESSNODELIST" _wirelessfinished.state`
      echo "done." >&6
    fi
    #


    #wait for wireless nodes
    set_master_state 0 wirlessfinished

  fi
  #end nodeinfostate

  if [ "x$state" = "xenvironment" ]; then
    if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
      echo -n "State: Prestart local process ... " >&6

      echo "Local process: prestart"
      RESULTDIR=$FINALRESULTDIR NODELIST="$NODELIST" $LOCALPROCESS prestart >> $FINALRESULTDIR/localapp.log

      echo "done." >&6
    fi
  fi

  if [ "x$state" = "xclickmodule" ]; then
    echo -n "State: Configure Clickmodule (if needed) and start measurement sessions ... " >&6

    #################################################
    ###### Start Measurement Screensession ##########
    #################################################

    MSCREENNUM=1
    MEASUREMENTSCREENNAME=measurement_$MEASUREMENT_ID\_$MSCREENNUM


    CURRENTMSCREENNUM=1

    NODEBINDIR="$DIR/../../nodes/bin"

    ########################################################
    ###### Setup Click-, Log- & Application-Stuff ##########
    ########################################################

    if [ -f $MSCREENFILENAME ]; then
      rm $MSCREENFILENAME
    fi

    touch $MSCREENFILENAME

    CURRENTMODE="RUN CLICK AND APPLICATION"
    RUN_CLICK_APPLICATION=0

    for node in $NODELIST; do
      NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`

      NODEARCH=`NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh "$NODEBINDIR/system.sh get_arch"`

      for nodedevice in $NODEDEVICELIST; do
        CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`

        CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
        CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
        LOGFILE=`echo "$CONFIGLINE" | awk '{print $8}'`

        if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then

          if [ $CURRENTMSCREENNUM -eq 1 ]; then
            screen -d -m -S $MEASUREMENTSCREENNAME
            sleep 0.2
          fi

          echo "$node $nodedevice $MEASUREMENTSCREENNAME" >> $MSCREENFILENAME

          RUN_CLICK_APPLICATION=1

          SCREENT="c_$node\_$nodedevice"
          screen -S $MEASUREMENTSCREENNAME -X screen -t $SCREENT
          CURRENTMSCREENNUM=`expr $CURRENTMSCREENNUM + 1`
          sleep 0.1
			
			if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
			    CLICKWAITTIME=`expr $TIME + 2`
			    screen -S $MEASUREMENTSCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"export CLICKPATH=$NODEBINDIR/../etc/click;CLICKPATH=$NODEBINDIR/../etc/click $NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT > /tmp/click/config; sleep $CLICKWAITTIME; echo "" > /tmp/click/config\""

			    sleep 0.1
			    SCREENT="k_$node\_$nodedevice"
			    screen -S $MEASUREMENTSCREENNAME -X screen -t $SCREENT
                            CURRENTMSCREENNUM=`expr $CURRENTMSCREENNUM + 1`
			    sleep 0.1
			    screen -S $MEASUREMENTSCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"LOGFILE=$LOGFILE $NODEBINDIR/click.sh kclick_start\""
			  else
			    sleep 0.1
			    #screen -S $MEASUREMENTSCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"export CLICKPATH=$NODEBINDIR/../etc/click;CLICKPATH=$NODEBINDIR/../etc/click $NODEBINDIR/click-align-$NODEARCH $CLICKSCRIPT | $NODEBINDIR/click-$NODEARCH  > $LOGFILE 2>&1\""
			    screen -S $MEASUREMENTSCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"$NODEBINDIR/click.sh start $CLICKSCRIPT $LOGFILE\""
			    sleep 0.1
			  fi
		  fi

		  APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`
		  APPLOGFILE=`echo "$CONFIGLINE" | awk '{print $10}'`
		
		  if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then

			  RUN_CLICK_APPLICATION=1

			  SCREENT="a_$node\_$nodedevice"
			  screen -S $MEASUREMENTSCREENNAME -X screen -t $SCREENT
			  CURRENTMSCREENNUM=`expr $CURRENTMSCREENNUM + 1`
			  sleep 0.1
			  screen -S $MEASUREMENTSCREENNAME -p $SCREENT -X stuff "NODELIST=$node $DIR/../../host/bin/run_on_nodes.sh \"export FINALRESULTDIR=$FINALRESULTDIR; export NODENAME=$node; $APPLICATION start > $APPLOGFILE 2>&1\""
		  fi

		  if [ $CURRENTMSCREENNUM -gt 25 ]; then
		    MSCREENNUM=`expr $MSCREENNUM + 1`
        	    MEASUREMENTSCREENNAME=measurement_$MEASUREMENT_ID\_$MSCREENNUM

        	    CURRENTMSCREENNUM=1
    		  fi
      done
    done

    echo "done." >&6

  fi

done

echo "Finished setup of nodes and screen-session"

#########################################
####### CREATE NODES-MAC FILE  ##########
#########################################

echo -n "" > nodes.mac
NODENUM=1

for node in $NODELIST; do
      NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`

      for nodedevice in $NODEDEVICELIST; do
        if [ -f status/$node\_wifiinfo.log ]; then
          MAC=`cat status/$node\_wifiinfo.log | grep $nodedevice | grep Link | grep -v "ESSID" | grep -v "Warni" | sed -e "s#^.*dr[a-z]*[[:space:]]##g" | cut -b 1-17`
          echo "$node $nodedevice $MAC $NODENUM" >> nodes.mac
          NODENUM=`expr $NODENUM + 1`
        fi
      done
done


#########################################################
####### Start Local Click- & Application-Stuff ##########
#########################################################

if [ $MEASUREMENT_ABORT -eq 0 ]; then

    echo -n "Start local application and remote dump ... " >&6
    LOCALSCREENNAME="local_$MEASUREMENT_ID"

    echo "check fo localstuff: $REMOTEDUMP ; $LOCALPROCESS" >> $FINALRESULTDIR/remotedump.log 2>&1 
    if [ "x$LOCALPROCESS" != "x" ] || [ "x$REMOTEDUMP" = "xyes" ]; then
      screen -d -m -S $LOCALSCREENNAME
      echo "check fo remote Dump: $REMOTEDUMP" >> $FINALRESULTDIR/remotedump.log 2>&1

      sleep 0.2
      if [ "x$REMOTEDUMP" = "xyes" ]; then
        echo "Start remotedump" >> $FINALRESULTDIR/remotedump.log 2>&1
        screen -S $LOCALSCREENNAME -X screen -t remotedump
        sleep 0.3
        screen -S $LOCALSCREENNAME -p remotedump -X stuff "(cd $FINALRESULTDIR/;export CLICKPATH=$NODEBINDIR/../etc/click;$NODEBINDIR/click-i586 $FINALRESULTDIR/remotedump.click >> $FINALRESULTDIR/remotedump.log 2>&1)"
        sleep 0.5
        screen -S $LOCALSCREENNAME -p remotedump -X stuff $'\n'
      fi

      sleep 0.2
      if [ "x$LOCALPROCESS" != "x" ]; then
        chmod u+x $LOCALPROCESS
        #echo "Debug: export PATH=$DIR/../../host/bin:$PATH;NODELIST=\"$NODELIST\" $LOCALPROCESS start >> $FINALRESULTDIR/localapp.log 2>&1"
        screen -S $LOCALSCREENNAME -X screen -t localprocess
        sleep 0.1
        screen -S $LOCALSCREENNAME -p localprocess -X stuff "export PATH=$DIR/../../host/bin:$PATH;RUNTIME=$TIME RESULTDIR=$FINALRESULTDIR NODELIST=\"$NODELIST\" $LOCALPROCESS start >> $FINALRESULTDIR/localapp.log 2>&1"
        sleep 0.5
        screen -S $LOCALSCREENNAME -p localprocess -X stuff $'\n'
      fi

    fi

    echo "done." >&6
fi
###################################################
####### Start Click- & Application-Stuff ##########
###################################################
if [ $MEASUREMENT_ABORT -eq 0 ]; then

    if [ $RUN_CLICK_APPLICATION -eq 1 ]; then

      echo -n "Start click and applications ... " >&6

      for node in $NODELIST; do
        NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
        for nodedevice in $NODEDEVICELIST; do
          CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`

          CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`

          CMEASUREMENTSCREENNAME=`cat $MSCREENFILENAME | grep "$node $nodedevice " | awk '{print $3}'`

          if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
            SCREENT="c_$node\_$nodedevice"
            screen -S $CMEASUREMENTSCREENNAME -p $SCREENT -X stuff $'\n'

            CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
            if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
              SCREENT="k_$node\_$nodedevice"
              screen -S $CMEASUREMENTSCREENNAME -p $SCREENT -X stuff $'\n'
            fi
          fi

          APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`

          if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then
            SCREENT="a_$node\_$nodedevice"
            screen -S $CMEASUREMENTSCREENNAME -p $SCREENT -X stuff $'\n'
          fi
        done
      done
      echo "done." >&6
    fi
fi
###################################################
################# Wait and Stop ###################
###################################################
if [ $MEASUREMENT_ABORT -eq 0 ]; then

  if [ $RUN_CLICK_APPLICATION -eq 1 ]; then

	  #add 10 second extra to make sure that we are not faster than the devices (click,application)
	  EXTRA_WAITTIME=20

	  if [ "x$NODENUM" != "x" ]; then
	    if [ $NODENUM -lt 5 ]; then
	      EXTRA_WAITTIME=5
	    fi
	    if [ $NODENUM -lt 20 ]; then
	      EXTRA_WAITTIME=10
	    fi
	  fi
	  WAITTIME=`expr $TIME + $EXTRA_WAITTIME`
	  echo "Wait for $WAITTIME sec"

	  # Countdown
	  echo -n -e "Wait... \033[1G" >&6
	  for ((i = $WAITTIME; i > 0; i--)); do
	    echo -n -e "Wait... $i \033[1G" >&6 ; sleep 1;
    done
	  echo -n -e "                 \033[1G" >&6
  fi
fi
###################################################
##### Kill progs for logfile for kclick  ##########
###################################################

kill_prog_and_logfiles

#######################################
##### Check Nodes and finish ##########
#######################################

check_nodes

#####################################
##### Close Screen-Session ##########
#####################################

close_measurement_screen

#################################################
#### Kill screen for all nodes (controller) #####
#################################################

close_node_screen

#######################################
##### Poststop local process ##########
#######################################

if [ ! "x$LOCALPROCESS" = "x" ] && [ -e $LOCALPROCESS ]; then
  echo "Stop local process"
  RESULTDIR=$FINALRESULTDIR $LOCALPROCESS poststop >> $FINALRESULTDIR/localapp.log
fi

echo "Finished measurement. Status: ok."

echo "0" > status/measurement_result.state

exit 0

