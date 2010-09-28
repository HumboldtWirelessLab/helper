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

if [ "x$POSTFIX" = "x" ]; then
    POSTFIX="real"
fi

if [ "x$WORKDIR" = "x" ]; then
    WORKDIR=$pwd
fi

if [ -f $2 ]; then
    DISCRIPTIONFILE=$2
     .  $DISCRIPTIONFILE
else
     echo "$2 : No such file !"
     exit 0;
fi

add_include() {
  echo "#include \"brn/helper.inc\""
  cat <&0 
  echo "#include \"brn/helper_tools.inc\""  
}


BASEDIR=$DIR/../../

case "$1" in
	"help")
		echo "Use $0 prepare"
		echo "Tool wich prepares the final skripts for a measurement (run_single_measurement). Replaces Variables ind the skript (like NODENAME, NODEDEVICE, ...)"
		;;
	"prepare")
		SIMDIS=$2
		. $SIMDIS

		SIMDISBASENAME=`basename $SIMDIS`
		cat $SIMDIS | sed "s#$NODETABLE#$RESULTDIR/$NODETABLE.$POSTFIX#g" | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $RESULTDIR/$SIMDISBASENAME.$POSTFIX

		if [ "x$REMOTEDUMP" = "xyes" ]; then
      if [ "x$DUMPPORTBASE" = "x" ]; then
		    DUMPPORTBASE=40000
		  fi
      if [ "x$DUMPIP" = "x" ]; then
		    DUMPIP="192.168.3.100"
		  fi
	  
		  echo -n "" > $RESULTDIR/remotedump.map
		  echo -n "" > $RESULTDIR/remotedump.click
    fi		  

		#Prepare click
		echo -n "" > $RESULTDIR/$NODETABLE.$POSTFIX
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
			    
			    if [ "x$ISGROUP" = "x1" ]; then
			      GROUP=`echo $CNODE | sed "s#group:##g"`
			      CNODES=`cat $CONFIGDIR/$GROUP | grep -v "#"`
			      #echo "NODES: $CNODE"
			    else
			      CNODES=$CNODE
			    fi
			    
			    for CNODE in $CNODES; do
			    
			      CPPOPTS="-DNODENAME=$CNODE -DNODEDEVICE=$CDEV -DTIME=$TIME"
			      
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
					          echo "Error: WIFICONFIG does'nt exist"
					          WIFICONFIGFINALNAME="-"
				          fi
				        fi
              fi
						
              CPPOPTS="$CPPOPTS -DWIFI=$WIFITYPE"
            else
				      WIFICONFIGFINALNAME="-"
			      fi
			
			      if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
			        #get full path of click-file
				      CLICK=`echo $CLICK | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`
			    
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
                    echo "Idle->Socket(UDP,$DUMPIP,$DUMPPORTBASE,$DUMPIP,$DUMPPORTBASE)->ToDump("$DUMPLINE");" | sed -e "s#NODEDEVICE#$CDEV#g" -e "s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" >> $RESULTDIR/remotedump.click
                    
                    NODEDUMPNR=`expr $NODEDUMPNR + 1`
                    DUMPPORTBASE=`expr $DUMPPORTBASE + 1`
                  done
                fi
                  
                #echo "SED: $DUMPSEDARG"
                CPPOPTS="$CPPOPTS -DDEBUG=$DEBUG"
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

                ( cd $CONFIGDIR; cat $CLICK | add_include | cpp -I$DIR/../etc/click $CPPOPTS | sed $DUMPSEDARG | sed $DIRSEDARG | grep -v "^#" >> $CLICKFINALNAME )
                
              else
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
	*)
		$0 help
		;;
esac

exit 0
