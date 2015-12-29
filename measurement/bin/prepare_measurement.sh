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

if [ "x$POSTFIX" = "x" ]; then
    POSTFIX="real"
fi

if [ "x$WORKDIR" = "x" ]; then
    WORKDIR=$pwd
fi

if [ "x$2" = "x" ]; then
  echo "Prepare measurement: 2. arg is missing"
else
  DESCRIPTIONFILE=$2

  if [ -f $DESCRIPTIONFILE ]; then
    . $DESCRIPTIONFILE
  else
     echo "$DESCRIPTIONFILE : No such file !"
     DESCRIPTIONFILE=""
  fi
fi


add_include() {
  if [ "x$1" = "x" ]; then
    echo "#include \"brn/helper.inc\""
  fi
  cat <&0 
  echo ""
  echo "#include \"brn/helper_tools.inc\""  
}


BASEDIR=$DIR/../../

case "$1" in
	"help")
		echo "Use $0 prepare"
		echo "Tool wich prepares the final skripts for a measurement (run_single_measurement). Replaces Variables ind the skript (like NODENAME, NODEDEVICE, ...)"
		;;
	"prepare")
		if [ "x$DESCRIPTIONFILE" = "x" ]; then
		  echo "No desc"
		  exit 0
		fi

		SIMDES=$DESCRIPTIONFILE
		. $SIMDES

		SIMDESBASENAME=`basename $SIMDES`
		cat $SIMDES | sed "s#$NODETABLE#$RESULTDIR/$NODETABLE.$POSTFIX#g" | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $RESULTDIR/$SIMDESBASENAME.$POSTFIX
		echo "" >> $RESULTDIR/$SIMDESBASENAME.$POSTFIX
		echo "CONFIGDIR=$CONFIGDIR" >> $RESULTDIR/$SIMDESBASENAME.$POSTFIX

		if [ "x$REMOTEDUMP" = "xyes" ]; then
      if [ "x$DUMPPORTBASE" = "x" ]; then
		    DUMPPORTBASE=40000
		  fi
      if [ "x$DUMPIP" = "x" ]; then
		    DUMPIP="192.168.3.2"
		  fi
	  
		  echo -n "" > $RESULTDIR/remotedump.map
		  echo -n "" > $RESULTDIR/remotedump.click
    fi		  

		#Prepare click
		echo -n "" > $RESULTDIR/$NODETABLE.$POSTFIX
		
		cp $DIR/../etc/templates/gen_clickscripts.sh $RESULTDIR/gen_clickscripts.sh

		while read line; do
		ISCOMMENT=`echo $line | grep "#" | wc -l`
		NOSPACELINE=`echo $line | sed -e "s#[[:space:]]##g"`
		
		if [ ! "x$NOSPACELINE" = "x" ]; then
			if [ $ISCOMMENT -eq 0 ]; then
			
			    #read CNODE CDEV CMODDIR CMODOPT WIFICONFIG CCMODDIR CLICK CCLOG CAPP CAPPL <<< $line
			    CNODE=`echo $line | awk '{print $1}'`
			    CDEV=`echo $line | awk '{print $2}'`
			    CMODDIR=`echo $line | awk '{print $3}'`
			    CMODOPT=`echo $line | awk '{print $4}'`
			    WIFICONFIG=`echo $line | awk '{print $5}'`
			    CCMODDIR=`echo $line | awk '{print $6}'`
			    CLICK=`echo $line | awk '{print $7}'`
			    CCLOG=`echo $line | awk '{print $8}'`
			    CAPP=`echo $line | awk '{print $9}'`
			    CAPPL=`echo $line | awk '{print $10}'`
			
			    WIFICONFIG=`echo "$WIFICONFIG" | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`

			    ISGROUP=`echo $CNODE | grep "group:" | wc -l`
			    ISRANDOM=`echo $CNODE | grep "random:" | wc -l`

			    if [ "x$ISGROUP" = "x1" ]; then
			      GROUP=`echo $CNODE | sed "s#:# #g" | awk '{print $2}'`

			      LIMIT=`echo $CNODE | sed "s#:# #g" | awk '{print $3}'`
			      if [ "x$LIMIT" = "x" ]; then
			         CNODES=`cat $CONFIGDIR/$GROUP | grep -v "#"`
			      else
			         #TODO: fix multiuse of file
			         CNODES=`cat $CONFIGDIR/$GROUP | grep -v "#" | head -n $LIMIT`
			      fi
			      #echo "NODES: $CNODE"
			    elif [ "x$ISRANDOM" = "x1" ]; then	
			      PARAMS=(`echo $CNODE | sed "s#:# #g"`)
			      if [ "x${PARAMS[1]}" != "x" ]; then
			      	NODE_NUMBER="-n ${PARAMS[1]}"
			      fi
			      	 
			      if [ "x${PARAMS[2]}" != "x" ]; then 
			      	FILE="-f ${PARAMS[2]}"
			      fi
			      
			      if [ "x${PARAMS[3]}" != "x" ]; then 
			      	ALGORITHM="-algo ${PARAMS[3]}"
			      fi
			      
			      if [ "x${PARAMS[4]}" != "x" ]; then 
			      	EXTRAPARAMS ="-paramlist ${PARAMS[4]}"
			      fi

			      CNODES=`cd ../../helper/src/subnetworkDiscovery/; java SubnetworkDiscovery $NODE_NUMBER $ALGORITHM $FILE $EXTRAPARAMS`
			    else
			      CNODES=$CNODE
			    fi
			    
			    for CNODE in $CNODES; do
			    
			      CPPOPTS="$EXTRACLICKFLAGS -DNODENAME=$CNODE -DNODEDEVICE=$CDEV -DTIME=$TIME"
			      
			      NODEINFILE=`cat $RESULTDIR/$NODETABLE.$POSTFIX | grep -e "^$CNODE[[:space:]]*$CDEV" | wc -l`
			      
			      if [ $NODEINFILE -ne 0 ]; then
			        #echo "Found node $CNODE with device $CDEV. Step over" 
			        continue
			      fi
			    
			      if [ ! "x$WIFICONFIG" = "x" ] && [ ! "x$WIFICONFIG" = "x-" ]; then
				      if [ -f  $CONFIGDIR/$WIFICONFIG ]; then
				        . $CONFIGDIR/$WIFICONFIG
				        WIFICONFIGFINALNAME=$CONFIGDIR/$WIFICONFIG
				      else
				        if [ -f  $DIR/../../nodes/etc/wifi/$WIFICONFIG ]; then
					        . $DIR/../../nodes/etc/wifi/$WIFICONFIG
					        WIFICONFIGFINALNAME="$DIR/../../nodes/etc/wifi/$WIFICONFIG"
				        else
					        if [ -f $WIFICONFIG ]; then
					          . $WIFICONFIG
					          WIFICONFIGFINALNAME="$WIFICONFIG"
					        else
					          echo "Error: WIFICONFIG doesn't exist"
					          WIFICONFIGFINALNAME="-"
				                fi
				        fi
                                      fi

				      if [ "x$WIFITYPE" = "xDEFAULT" ] || [ "x$WIFITYPE" = "x0" ]; then
				        WIFITYPE="\$WIFITYPEDEFAULT"
				      fi
                                      CPPOPTS="$CPPOPTS -DWIFITYPE=$WIFITYPE"
                              else
				      WIFICONFIGFINALNAME="-"
			      fi
			
			      if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
			        #get full path of click-file
				      CLICK=`echo $CLICK | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`

              #echo $CLICK

              if [ -e $CLICK ] || [ -e $CONFIGDIR/$CLICK ]; then
                CLICKBASENAME=`basename $CLICK`
                CLICKFINALNAME="$RESULTDIR/$CLICKBASENAME.$CNODE.$CDEV"
                if [ "x$DEBUG" = "x" ]; then
                  DEBUG=2
                else
                  if [ $DEBUG -gt 4 ] || [ $DEBUG -lt 0 ]; then
                    DEBUG=2
                  fi
                fi

                echo -n "" > $CLICKFINALNAME

                ###################
                ### Remote Dump ###
                ###################
                DUMPSEDARG=" -e s#-#-#g"

                if [ "x$REMOTEDUMP" = "xyes" ]; then
                  CPPOPTS="$CPPOPTS -DREMOTEDUMP -DDUMPMAC=$DUMPMAC -DDUMPIP=$DUMPIP"

                  DUMPS=`(cd $CONFIGDIR; cat $CLICK | add_include | awk '/TODUMP/ {print NR" "$0}' | grep -v "^[1-9]*[[:space:]]*//" | awk '{print $1}')`

                  NODEDUMPNR=1;

                  for i in $DUMPS; do
                    DUMPLINE=`( cd $CONFIGDIR; cat $CLICK | grep -v "^//" | grep "TODUMP" | head -n $NODEDUMPNR | tail -n 1 | sed -e "s#^.*TODUMP(##g" -e "s#).*##g" )`
                    echo "$CNODE $CDEV $NODEDUMPNR $DUMPLINE $DUMPIP $DUMPPORTBASE" | sed -e "s#NODEDEVICE#$CDEV#g" -e "s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" >> $RESULTDIR/remotedump.map

                    DUMPSEDARG="$DUMPSEDARG -e s#DUMPPORT@$i#$DUMPPORTBASE#g"
                    echo "Idle->Socket(UDP,$DUMPIP,$DUMPPORTBASE,$DUMPIP,$DUMPPORTBASE)->TimestampDecap()->ToDump("$DUMPLINE");" | sed -e "s#NODEDEVICE#$CDEV#g" -e "s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" >> $RESULTDIR/remotedump.click

                    NODEDUMPNR=`expr $NODEDUMPNR + 1`
                    DUMPPORTBASE=`expr $DUMPPORTBASE + 1`
                  done
                fi

                #echo "SED: $DUMPSEDARG"
                DEVICENUMBER=`echo $CDEV | sed -e 's#[a-zA-Z]*##g'`
                CPPOPTS="$CPPOPTS -DDEBUGLEVEL=$DEBUG -DDEVICENUMBER=$DEVICENUMBER"
                DIRSEDARG="-e s#NODEDEVICE#$CDEV#g -e s#NODENAME#$CNODE#g -e s#RESULTDIR#$RESULTDIR#g -e s#WORKDIR#$WORKDIR#g -e s#BASEDIR#$BASEDIR#g"

                if [ "$CCMODDIR" = "-" ] || [ "x$CLICKMODE" = "xuserlevel" ]; then
                  CPPOPTS="$CPPOPTS -DUSERLEVEL"
                else
                  CPPOPTS="$CPPOPTS -DKERNEL"
                fi

                if [ "$CCMODDIR" = "-" ] || [ "x$CLICKMODE" = "xuserlevel" ]; then
                  if [ "x$CONTROLSOCKET" != "xno" ]; then
                     CPPOPTS="$CPPOPTS -DCONTROLSOCKET"
                  fi
                fi

                #echo "$CPPOPTS"

                HELPER_INC=`(cd $CONFIGDIR; cat $CLICK | grep -v "^//" | grep "helper.inc" | wc -l)`

                CPPOPTS="$CPPOPTS -I$CONFIGDIR"

                #echo $CPPOPTS

                MODDIR=`echo "$CMODDIR" | sed $DIRSEDARG`
                echo "WIFITYPEDEFAULT=\`get_wifitype $CNODE $CDEV $MODDIR $CMODOPT $RESULTDIR/status/all_nodeinfo.log\`" >> $RESULTDIR/gen_clickscripts.sh
                if [ $HELPER_INC -gt 0 ]; then
                  echo "( cd $CONFIGDIR; cat $CLICK | add_include no | cpp -I$DIR/../etc/click $CPPOPTS | sed $DUMPSEDARG | sed $DIRSEDARG | grep -v '^#' >> $CLICKFINALNAME )" >> $RESULTDIR/gen_clickscripts.sh
                  #( cd $CONFIGDIR; cat $CLICK | add_include no | cpp -I$DIR/../etc/click $CPPOPTS | sed $DUMPSEDARG | sed $DIRSEDARG | grep -v "^#" >> $CLICKFINALNAME )
                else
                  echo "( cd $CONFIGDIR; cat $CLICK | add_include | cpp -I$DIR/../etc/click $CPPOPTS | sed $DUMPSEDARG | sed $DIRSEDARG | grep -v '^#' >> $CLICKFINALNAME )" >> $RESULTDIR/gen_clickscripts.sh
                  #( cd $CONFIGDIR; cat $CLICK | add_include | cpp -I$DIR/../etc/click $CPPOPTS | sed $DUMPSEDARG | sed $DIRSEDARG | grep -v "^#" >> $CLICKFINALNAME )
                fi
              else
                if [ ! -e $CLICK ]; then
                   echo "WARNING: clickfile ($CLICK) not found."
                fi
                CLICKFINALNAME="-"
              fi
            else
              CLICKFINALNAME="-"
            fi

            echo "$CNODE $CDEV $CMODDIR $CMODOPT $WIFICONFIGFINALNAME $CCMODDIR $CLICKFINALNAME $CCLOG $CAPP $CAPPL" | sed -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" -e "s#NODENAME#$CNODE#g" -e "s#NODEDEVICE#$CDEV#g" >> $RESULTDIR/$NODETABLE.$POSTFIX

          done
        fi
      fi
   done < $CONFIGDIR/$NODETABLE

		if [ "x$REMOTEDUMP" = "xyes" ]; then
		  REMOTEDUMPTIME=`expr $TIME + 5`
		  echo "Script(wait $REMOTEDUMPTIME, stop);" >> $RESULTDIR/remotedump.click
		fi
				
		;;
	"afterwards")
		HELPERDIR=$DIR/../../ sh $RESULTDIR/gen_clickscripts.sh
		;;
		
	*)
		$0 help
		;;
esac

exit 0
