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

############################
###### Leave pid  ##########
############################
LOGMARKER=$NODELIST

echo $$ > status/$LOGMARKER\_nodectrl.pid

############################
###### Start node setup ####
############################

. $DIR/../../host/bin/functions.sh

MEASUREMENT_ABORT=0
CRUNMODENUM=1
CURRENTMODE="START"

##############################
###### SYNC - stuff ##########
##############################

wait_for_master_state() {
  DEBUGFILE=status/wait_$1\_$2
#  DEBUGFILE=/dev/null

  echo "wait for master" >> $DEBUGFILE

  while [ ! -f status/master_$1.state ] && [ ! -f status/master_abort.state ]; do
    if [ -f status/master_$1.state ]; then
      echo "got status/master_$1.state" >> $DEBUGFILE
    fi

    echo "wait for master" >> $DEBUGFILE
    sleep 1
  done

  cat status/master_$1.state | awk '{print $1}'
}

set_node_state() {
  echo "$3" >  status/$0\_$2.state
}

##############################################
###### Functions to check the nodes ##########
##############################################

#TODO use abort-function if node check fails 
check_nodes() {

    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh statusmarker`

    if [ ! "x$NODESTATUS" = "xok" ]; then
	    echo "Nodestatus: $NODESTATUS" >> status/$NODELIST\_error.log 2>&1
	    echo "WHHHHOOOOO: LOOKS LIKE RESTART! GOD SAVE THE WATCHDOG" >> status/$NODELIST\_error.log 2>&1
	    echo "Current Mode: $CURRENTMODE" >> status/$NODELIST\_error.log 2>&1
	    echo "Node: $NODELIST" >> status/$NODELIST\_error.log 2>&1
	    echo "reboot the node" >> status/$NODELIST\_error.log 2>&1
	    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot >> status/$NODELIST\_error.log 2>&1

	    echo "wait for the node" >> status/$NODELIST\_error.log 2>&1
	    sleep 20
	    echo "error" >> status/$NODELIST\_error.log 2>&1
	
	    (echo "1" > $1)
    fi
}

get_node_status()  {
    NODESTATUS=`NODELIST=$NODELIST MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh statusmarker`
    echo "$NODESTATUS"
}

#############################################
###### Kill Click and Application  ##########
#############################################

kill_everything() {

CRUNMODENUM=9

echo "Kill Click and stop application on Nodes:" >> status/$LOGMARKER\_killclick.log 2>&1
for node in $NODELIST; do
  NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`

  for nodedevice in $NODEDEVICELIST; do
    echo "$node" >> status/$LOGMARKER\_killclick.log

    CONFIGLINE=`cat $CONFIGFILE | egrep "^$node[[:space:]]+$nodedevice"`
    CLICKMODDIR=`echo "$CONFIGLINE" | awk '{print $6}'`
    CLICKSCRIPT=`echo "$CONFIGLINE" | awk '{print $7}'`
    if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ] && [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
      NODELIST="$node" MODULSDIR=$CLICKMODDIR $DIR/../../host/bin/click.sh kclick_stop >> status/$LOGMARKER\_killclick.log 2>&1
      NODELIST="$node" MODULSDIR=$CLICKMODDIR $DIR/../../host/bin/click.sh rmmod >> status/$LOGMARKER\_killclick.log 2>&1
    else
      if [ ! "x$CLICKSCRIPT" = "x" ] && [ ! "x$CLICKSCRIPT" = "x-" ]; then
        run_on_node $node "$DIR/../../nodes/bin/click.sh stop" "/" $DIR/../etc/keys/id_dsa
      fi
    fi

    APPLICATION=`echo "$CONFIGLINE" | awk '{print $9}'`

    if [ ! "x$APPLICATION" = "x" ] && [ ! "x$APPLICATION" = "x-" ]; then
      run_on_node $node "$APPLICATION  stop" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_killclick.log 2>&1
    fi
    echo " done" >> status/$LOGMARKER\_killclick.log 2>&1
  done
done

echo "0" > status/$LOGMARKER\_killclick.state

}

#######################################
##### Check Nodes and finish ##########
#######################################

final_node_check() {

CRUNMODENUM=10

wait_for_master_state killmeasurement $LOGMARKER

echo "Check nodes" >> status/$LOGMARKER\_finalnodecheck.log 2>&1

check_nodes status/$LOGMARKER\_finalnodecheck.state >> status/$LOGMARKER\_finalnodecheck.log 2>&1

echo "0" > status/$LOGMARKER\_finalnodecheck.state

}

######################################################
############ Abort measurement #######################
######################################################


abort_measurement() {

  echo "Abort Measurement" >> status/$LOGMARKER\_abort_measurement.log

  if [ $CRUNMODENUM -ge 8 ]; then
    kill_everything
  else
    echo "0" > status/$LOGMARKER\_killclick.state
  fi

  if [ "x$MODE" = "xwireless" ]; then
    for node in $NODELIST; do
      scp -i $DIR/../../host/etc/keys/id_dsa -r root@$node:$FINALRESULTDIR/ $FINALRESULTDIR/../ > status/$LOGMARKER\_copy_result.log 2>&1
      run_on_node $node "rm -rf $FINALRESULTDIR/" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_copy_result.log 2>&1
      echo "Done" >> status/$LOGMARKER\_copy_result.log 2>&1
    done
  fi

  wait_for_master_state killmeasurement $LOGMARKER
  echo "Check nodes" >> status/$LOGMARKER\_finalnodecheck.log 2>&1
  echo "0" > status/$LOGMARKER\_finalnodecheck.state
# final_node_check

  exit 0
}

trap abort_measurement 2 15 1 3 4 5 6 7 8 9 10 11 12 13 14

echo "Register trap" > status/$LOGMARKER\_abort_measurement.log

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



###############################
###### Wait for node ##########
###############################
CRUNMODENUM=1

echo "$NODELIST" > status/$LOGMARKER\_reboot.log 2>&1

echo "check node $NODELIST" >> status/$LOGMARKER\_reboot.log
NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodes >> status/$LOGMARKER\_reboot.log 2>&1

# Check state of node: reboot requiered ??

if [ $RUNMODENUM -eq 0 ]; then
    CRUNMODENUM=0
    echo -n "Check marker ($MARKER): " >> status/$LOGMARKER\_reboot.log 2>&1
    CHECKNODESTATUS=`get_node_status`
    echo "$CHECKNODESTATUS" >> status/$LOGMARKER\_reboot.log 2>&1
    if [ ! "x$CHECKNODESTATUS" = "xok" ]; then
	    RUNMODENUM=1
    else
	    RUNMODENUM=5
    fi
fi


###############################
###### get node info ##########
###############################

MODE=`NODELIST="$NODELIST" $DIR/../../host/bin/system.sh backbone | awk '{print $2}'`

if [ "x$MODE" = "xwireless" ]; then
  NODELIST="$NODELIST" $DIR/../../host/bin/system.sh nodeinfo > status/$LOGMARKER\_nodeinfo.log 2>&1
  OLSR="no"
else
  echo -n "" > status/$LOGMARKER\_nodeinfo.log 2>&1
  OLSR=`NODELIST="$NODELIST" $DIR/../../host/bin/system.sh olsrbackbone`
fi

echo "0" > status/$LOGMARKER\_nodeinfo.state

#####################################
## Wireless nodes wait for package ##
#####################################

if [ "x$MODE" = "xwireless" ]; then
  #wait for package (build by master)
  wait_for_master_state wirelesspackage $LOGMARKER

  #package is ready. let's go

  ############### reboot ###############
  #Don't reboot. just set set marker
  echo "0" > status/$LOGMARKER\_reboot.state

  ############# environment ###############
  echo "Start nodecheck" > status/$LOGMARKER\_environment.log 2>&1
  NODELIST="$NODELIST" $DIR/../../host/bin/system.sh start_node_check >> status/$LOGMARKER\_environment.log 2>&1

  echo "Handle wireless node" >> status/$LOGMARKER\_environment.log 2>&1
  echo "Set marker for reboot-detection $NODELIST" >> status/$LOGMARKER\_environment.log 2>&1
  NODELIST="$NODELIST" MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh setmarker >> status/$LOGMARKER\_environment.log 2>&1

  echo "mount tmpfs"  >> status/$LOGMARKER\_environment.log 2>&1
  NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh mounttmpfs >> status/$LOGMARKER\_environment.log 2>&1

  echo "Start node test"  >> status/$LOGMARKER\_environment.log 2>&1
  NODELIST="$NODELIST" $DIR/../../host/bin/system.sh start_node_check >> status/$LOGMARKER\_environment.log 2>&1

  echo -n "Check node test: "  >> status/$LOGMARKER\_environment.log 2>&1
  NODELIST="$NODELIST" $DIR/../../host/bin/system.sh test_node_check >> status/$LOGMARKER\_environment.log 2>&1

  #TODO: get name from elsewhere
  FILENAME="pack_file.tar.bz2" 

  echo "copy"  >> status/$LOGMARKER\_environment.log 2>&1 
  FILE="$FILENAME" TARGETDIR=/tmp NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh scp_remote >> status/$LOGMARKER\_environment.log 2>&1

  echo "unpack"  >> status/$LOGMARKER\_environment.log 2>&1
  FILE="$FILENAME" TARGETDIR=/tmp NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh unpack_remote >> status/$LOGMARKER\_environment.log 2>&1
  echo "0" > status/$LOGMARKER\_environment.state
  echo "0" > status/$LOGMARKER\_wirelesspackage.state


  ############# wireless  ###############
  wait_for_master_state wirelessstart $LOGMARKER

  for node in $NODELIST; do

    MODULSDIR=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $3}' | tail -n 1`
    MODOPTIONS=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $4}' | tail -n 1`
    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $5}' | tail -n 1`
    NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`

    for device in $NODEDEVICELIST; do
      run_on_node $node "RUNMODE=DRIVER MODULSDIR=$MODULSDIR MODOPTIONS=$MODOPTIONS CONFIG=$CONFIG DEVICE=$device $DIR/../../nodes/lib/standalone/standalone.sh setup" "/" $DIR/../etc/keys/id_dsa
    done

  done

  echo "0" > status/$LOGMARKER\_wirelessfinished.state
  echo "0" > status/$LOGMARKER\_wifimodules.state
  echo "0" > status/$LOGMARKER\_wificonfig.state

  echo "Start wifidev" > status/wireless_node_wait_$LOGMARKER\.state
  date >> status/wireless_node_wait_$LOGMARKER\.state

  sleep 120

  #set
  RUNMODENUM=5

  ############ finished wireless ###########

else
  if [ "x$OLSR" = "xyes" ]; then
    echo "0" > status/$LOGMARKER\_olsr.info
    wait_for_master_state wirlessfinished $LOGMARKER

    if [ $RUNMODENUM -le 1 ]; then
      RUNMODENUM=2
    fi
  fi
fi

###############################################
###### Reboot node and wait for them ##########
###############################################

if [ $RUNMODENUM -le 1 ]; then
    echo "Reboot node $NODELIST" >> status/$LOGMARKER\_reboot.log 2>&1
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh reboot >> status/$LOGMARKER\_reboot.log 2>&1

    echo "Wait for node $NODELIST" >> status/$LOGMARKER\_reboot.log 2>&1
    for s in `seq 1 30`; do
      sleep 1
    done
    NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodesandssh >> status/$LOGMARKER\_reboot.log 2>&1
fi

echo "0" > status/$LOGMARKER\_reboot.state

###################################
####### Reboot Detection ##########
###################################

if [ "x$MODE" != "xwireless" ]; then
  echo "Set marker for reboot-detection $NODELIST" >> status/$LOGMARKER\_environment.log 2>&1

  NODELIST="$NODELIST" MARKER="/tmp/$MARKER" $DIR/../../host/bin/status.sh setmarker >> status/$LOGMARKER\_environment.log 2>&1
fi

###################################
###### Setup Environment ##########
###################################
CRUNMODENUM=2

if [ $RUNMODENUM -le 2 ]; then
    echo "Setup environment $NODELIST" > status/$LOGMARKER\_environment.log 2>&1
    NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh mount >> status/$LOGMARKER\_environment.log 2>&1
    NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh extramount >> status/$LOGMARKER\_environment.log 2>&1
    NODELIST="$NODELIST" $DIR/../../host/bin/environment.sh settime >> status/$LOGMARKER\_environment.log 2>&1
fi

echo "0" > status/$LOGMARKER\_environment.state

##################################
###### Load Wifi-Moduls ##########
##################################
CRUNMODENUM=3

if [ $RUNMODENUM -le 3 ]; then

    echo "Load Modules" > status/$LOGMARKER\_wifimodules.log 2>&1
    CURRENTMODE="LOAD MODULES"
    LOADMODULES=0

    echo "OLSR: $OLSR" > status/$LOGMARKER\_olsr_status.log 2>&1
    if [ "x$OLSR" = "xyes" ]; then
      for node in $NODELIST; do
         run_on_node $node "$DIR/../../nodes/lib/backbone/backbone.sh stop_backbone" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_olsr_status.log 2>&1
      done
    fi

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

          NODELIST="$node" MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../host/bin/wlanmodules.sh rmmod >> status/$LOGMARKER\_wifimodules.log 2>&1
          NODELIST="$node" MODOPTIONS=$MODOPTIONS MODULSDIR=$MODULSDIR $DIR/../../host/bin/wlanmodules.sh insmod >> status/$LOGMARKER\_wifimodules.log 2>&1
          LOADMODULES=1
      fi
    done

    if [ "x$DISABLE_WIRELESS_BACKBONE" = "xyes" ]; then
      echo "Disable Wireless backbone by request" >> status/$LOGMARKER\_olsr_status.log 2>&1
    else
      if [ "x$OLSR" = "xyes" ]; then
        for node in $NODELIST; do
          run_on_node $node "$DIR/../../nodes/lib/backbone/backbone.sh start_backbone" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_olsr_status.log 2>&1
        done
      fi
    fi

    if [ $LOADMODULES -eq 1 ]; then
	    #check nodes and sleep, only if modules are need to load
	    check_nodes status/$LOGMARKER\_wifimodules.state >> status/$LOGMARKER\_wifimodules.log 2>&1
	    sleep 1
    fi


fi

echo "0" > status/$LOGMARKER\_wifimodules.state

############################
###### Setup Wifi ##########
############################
CRUNMODENUM=4

if [ $RUNMODENUM -le 4 ]; then

  echo "Setup Wifi" > status/$LOGMARKER\_wificonfig.log 2>&1
  CURRENTMODE="CREATE WIFI"
  CREATEWIFI=0

  for node in $NODELIST; do
	  NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	  for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		    NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh create >> status/$LOGMARKER\_wificonfig.log 2>&1
		    CREATEWIFI=1
	    fi
	  done
  done

  if [ $CREATEWIFI -eq 1 ]; then
          #check nodes and sleep if device should be created
	  check_nodes status/$LOGMARKER\_wificonfig.state >> status/$LOGMARKER\_wificonfig.log 2>&1
	  sleep 1
	  #extra sleep for WGTs
	  sleep 2
  fi

  CURRENTMODE="CONFIG WIFI PRE START"
  STARTWIFI=0

  for node in $NODELIST; do
	  NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	  for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		    NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh config_pre_start >> status/$LOGMARKER\_wificonfig.log 2>&1
	    fi
	  done
  done

  CURRENTMODE="START WIFI"

  for node in $NODELIST; do
    NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
    for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh start >> status/$LOGMARKER\_wificonfig.log 2>&1
	        STARTWIFI=1
	    fi
    done
  done

  if [ $STARTWIFI -eq 1 ]; then
    check_nodes status/$LOGMARKER\_wificonfig.state >> status/$LOGMARKER\_wificonfig.log 2>&1
    sleep 1
  fi

  CURRENTMODE="CONFIG WIFI POST START"
  CONFIGWIFI=0

  for node in $NODELIST; do
	  NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
	  for nodedevice in $NODEDEVICELIST; do
	    CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
		    NODE=$node DEVICES=$nodedevice CONFIG="$CONFIG" $DIR/../../host/bin/wlandevices.sh config_post_start >> status/$LOGMARKER\_wificonfig.log 2>&1
		    CONFIGWIFI=1
	    fi
	  done
  done

  if [ $CONFIGWIFI -eq 1 ]; then
    check_nodes status/$LOGMARKER\_wificonfig.state >> status/$LOGMARKER\_wificonfig.log 2>&1
    sleep 1
  fi

fi

echo "0" > status/$LOGMARKER\_wificonfig.state

##############################
###### Wireless nodes ########
##############################

if [ "x$MODE" = "xwireless" ]; then
  echo "Wait for wifidev" >> status/wireless_node_wait_$LOGMARKER\.state
  date >> status/wireless_node_wait_$LOGMARKER\.state

  #wait for own node. maybe link to wireless node is broken due to setup a gateway node
  NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodesandssh > status/$LOGMARKER\_wireless_node_test.log 2>&1
  check_nodes status/$LOGMARKER\_wireless_node.state >> status/$LOGMARKER\_wireless_node_test.log 2>&1

  echo "wifidev is up" >> status/wireless_node_wait_$LOGMARKER\.state
  date >> status/wireless_node_wait_$LOGMARKER\.state
fi

##############################
###### Get Wifiinfo ##########
##############################
#TODO: rename nodelist
CRUNMODENUM=5

if [ $RUNMODENUM -le 5 ]; then

  echo "Get Wifiinfo" > status/$LOGMARKER\_wifiinfo.log 2>&1

  for node in $NODELIST; do
    NODEDEVICELIST=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $2}'`
    for nodedevice in $NODEDEVICELIST; do
      CONFIG=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`
	    echo "Deviceconfig for $node:$nodedevice" >> status/$LOGMARKER\_wifiinfo.log 2>&1
	    if [ ! "x$CONFIG" = "x" ] && [ ! "x$CONFIG" = "x-" ]; then
               NODE=$node DEVICES=$nodedevice $DIR/../../host/bin/wlandevices.sh getiwconfig >> status/$LOGMARKER\_wifiinfo.log 2>&1
	    fi

	    if [ "x$WANTNODELIST" = "xyes" ]; then
	      MADDR=`run_on_node $node "DEVICE=$nodedevice $DIR/../../nodes/bin/wlandevice.sh getmac" "/" $DIR/../../host/etc/keys/id_dsa`
	      echo "$node $nodedevice $MADDR" >> $FINALRESULTDIR/nodelist_$NODELIST
	    fi

	  done
  done

fi

echo "0" > status/$LOGMARKER\_wifiinfo.state

###################################
###### Setup Clickmodule ##########
###################################

CRUNMODENUM=6
CURRENTMODE="LOAD CLICKMOD" > status/$LOGMARKER\_clickmodule.log 2>&1
LOADCLICKMOD=0

if [ "x$MODE" != "xwireless" ]; then

  for node in $NODELIST; do

    CLICKMODDIR=`cat $CONFIGFILE | egrep "^$node[[:space:]]" | awk '{print $6}' | tail -n 1`

    if [ ! "x$CLICKMODDIR" = "x" ] && [ ! "x$CLICKMODDIR" = "x-" ] && [ ! "x$CLICKMODE" = "xuserlevel" ]; then
      NODELIST="$node" MODULSDIR=$CLICKMODDIR $DIR/../../host/bin/click.sh reloadmod >> status/$LOGMARKER\_clickmodule.log 2>&1
      LOADCLICKMOD=1
    fi
  done

  if [ $LOADCLICKMOD -eq 1 ]; then
    check_nodes status/$LOGMARKER\_clickmodule.state >> status/$LOGMARKER\_clickmodule.log 2>&1
  fi

fi
#wireless node will load the module earlier

echo "0" > status/$LOGMARKER\_clickmodule.state

########################################################
###### Preload Click-, Log- & Application-Stuff ########
########################################################

CRUNMODENUM=7
NODEBINDIR="$DIR/../../nodes/bin"
CURRENTMODE="PRELOAD CLICK"

if [ "x$MODE" != "xwireless" ]; then
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
        run_on_node $node "cat $APPLICATION > /dev/null" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_preload.log 2>&1
      fi
    done

    if [ "x$LOADCLICK" = "x1" ]; then
      echo "Click preload on $node" >> status/$LOGMARKER\_preload.log
      run_on_node $node "export CLICKPATH=$NODEBINDIR/../etc/click;echo \"Script(wait 0,stop);\" | $NODEBINDIR/click-align-$NODEARCH | $NODEBINDIR/click-$NODEARCH" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_preload.log 2>&1
    fi
  done
fi

if [ "x$MODE" = "xwireless" ]; then
  #wait for own node. maybe link to wireless node is broken due to setup a gateway node
  #check here again, since next step is starting the measurement
  NODELIST="$NODELIST" $DIR/../../host/bin/system.sh waitfornodesandssh > status/$LOGMARKER\_wireless_node_test_2.log 2>&1
  check_nodes status/$LOGMARKER\_wireless_node.state >> status/$LOGMARKER\_wireless_node_test_2.log 2>&1
fi

echo "0" > status/$LOGMARKER\_preload.state

#############################################
######### WAIT FOR CLICK FINISHED ###########
#############################################

CRUNMODENUM=8
CURRENTMODE="RUN CLICK"

wait_for_master_state measurement $LOGMARKER

############ Kill everything ################

kill_everything

if [ "x$MODE" = "xwireless" ]; then
  for node in $NODELIST; do
    scp -i $DIR/../../host/etc/keys/id_dsa -r root@$node:$FINALRESULTDIR/ $FINALRESULTDIR/../ > status/$LOGMARKER\_copy_result.log 2>&1
    run_on_node $node "rm -rf $FINALRESULTDIR/" "/" $DIR/../../host/etc/keys/id_dsa >> status/$LOGMARKER\_copy_result.log 2>&1
  done
fi

############ Final Check ################

final_node_check

exit 0
