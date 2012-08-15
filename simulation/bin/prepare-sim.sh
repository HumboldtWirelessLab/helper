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

. $DIR/../../measurement/etc/wifitypes

add_include() {
  if [ "x$1" = "x0" ]; then
    echo "#include \"brn/helper.inc\""
  fi
  cat <&0
  echo ""
  echo "#include \"brn/helper_tools.inc\""  
}

if [ "x$POSTFIX" = "x" ]; then
    POSTFIX="simulation"
fi

BASEDIR=$DIR/../../

if [ "x$USED_SIMULATOR" = "x" ]; then
  USED_SIMULATIOR=ns
fi

if [ "$USED_SIMULATOR" != "jist" ] && [ "$USED_SIMULATOR" != "ns" ] && [ "$USED_SIMULATOR" != "ns3" ]; then
  echo "USED_SIMULATOR is unknown ($USED_SIMUALTOR). Use ns, ns3 or jist."
  exit 0
fi

if [ "x$LOGLEVEL" = "x1" ]; then echo "sim is $USED_SIMULATOR"; fi

case "$1" in
	"help")
		echo "Use $0 prepare dis-file"
		;;
	"prepare")
		SIMDIS=$2
		. $SIMDIS
		
		if [ "x$WORKDIR" = "x" ]; then
		    WORKDIR=$RESULTDIR
		fi
		
		echo -n "" > $RESULTDIR/$NODETABLE.$POSTFIX
		while read line; do
		    ISCOMMENT=`echo $line | grep "#" | wc -l`
		    if [ $ISCOMMENT -eq 0 ]; then
		    
	              read CNODE CDEV CMODDIR CMODOPT WIFICONFIG CCMODDIR CLICK CCLOG CAPP CAPPL <<< $line
			
	              ISGROUP=`echo $CNODE | grep "group:" | wc -l`
			      
		      if [ "x$ISGROUP" = "x1" ]; then
		        GROUP=`echo $CNODE | sed "s#group:##g"`
			HASLIMIT=`echo $GROUP | grep ":" | wc -l`
			
			if [ $HASLIMIT -eq 1 ]; then
			  GROUP_LIMIT=`echo $GROUP | sed -e "s#.*:##g"`
			  GROUP=`echo $GROUP | sed -e "s#:.*##g"`
			  #echo "$GROUP $GROUP_LIMIT"
			else
			  GROUP_LIMIT=0
			fi 
			
		        CNODES=`cat $CONFIGDIR/$GROUP | grep -v "#"`
		        #echo "NODES: $CNODE"
		      else
	                ISRANDOM=`echo $CNODE | grep "random:" | wc -l`
			
			LIMIT=`echo $CNODE | sed "s#random:##g"`
			
			if [ $ISRANDOM -gt 0 ] && [ "x$LIMIT" != "x" ]; then
			  NO_NODES=0
			  AC_NODEID=1
			
			  CNODES=""
			  while [ $NO_NODES -lt $LIMIT ]; do
			    NEW_NODE="sk$AC_NODEID"
			    
			    AC_NODEID=`expr $AC_NODEID + 1`
			    			    
			    NODEINFILE=`cat $RESULTDIR/$NODETABLE.$POSTFIX | grep -e "^$NEW_NODE[[:space:]]*" | wc -l`
			    NODEINFILE2=`cat $CONFIGDIR/$NODETABLE | grep -e "^$NEW_NODE[[:space:]]*" | wc -l`

			    if [ $NODEINFILE -eq 0 ] && [ $NODEINFILE2 -eq 0 ]; then
			      CNODES="$CNODES $NEW_NODE"
			      NO_NODES=`expr $NO_NODES + 1`
			    fi
			  
			  done
			  
			  GROUP_LIMIT=0
			  
			else
		          CNODES=$CNODE
			  GROUP_LIMIT=0
			fi
        	      fi

                      NODES_OF_GROUP=0

		      for CNODE in $CNODES; do

			if [ $GROUP_LIMIT -ne 0 ]; then
			  if [ $NODES_OF_GROUP -eq $GROUP_LIMIT ]; then
			    #echo "Reach Nodeslimit: $NODES_OF_GROUP of $GROUP_LIMIT"
			    break;
			  fi
			fi

		        if [ "x$USED_SIMULATOR" = "xns" ] || [ "x$USED_SIMULATOR" = "xns3" ]; then
			  DEVICE_TMPL=`echo $CDEV | grep "dev" | wc -l`
			  if [ $DEVICE_TMPL -eq 0 ]; then
			    CDEV=eth0
			  else
			    CDEV=`echo $CDEV | sed "s#DEV##g"`
			    CDEV="eth$CDEV"
			  fi
			else
			  DEVICE_TMPL=`echo $CDEV | grep "dev" | wc -l`
			  if [ $DEVICE_TMPL -eq 0 ]; then
			    CDEV=ath0
			  else
			    CDEV=`echo $CDEV | sed "s#DEV##g"`
			    CDEV="ath$CDEV"
			  fi
                        fi
			
		        NODEINFILE=`cat $RESULTDIR/$NODETABLE.$POSTFIX | grep -e "^$CNODE[[:space:]]*$CDEV" | wc -l`
			
        		if [ $NODEINFILE -ne 0 ]; then
            		    #echo "Found node $CNODE with device $CDEV. Step over"  
			    continue
			else
			  NODES_OF_GROUP=`expr $NODES_OF_GROUP + 1`
			fi
		      
		        
            if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
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
	
                if [ ! -f $WIFICONFIG ]; then
                  if [ -f $DIR/../../nodes/etc/wifi/$WIFICONFIG ]; then
		      WIFICONFIG="$DIR/../../nodes/etc/wifi/$WIFICONFIG"
		  else
		      WIFICONFIG="$DIR/../../nodes/etc/wifi/monitor.default"
		  fi
		fi
		
		#echo "$WIFICONFIG"
																			    
		. $WIFICONFIG
		
	        if [ "x$USED_SIMULATOR" = "xjist" ]; then	
		  cp $WIFICONFIG $RESULTDIR
		  
		  if [ "x$WIFITYPE" = "x" ] || [ "x$WIFITYPE" = "x0" ] || [ "x$WIFITYPE" = "xDEFAULT" ]; then
		    WIFITYPE=$WIFITYPE_EXTRA
		  fi
		  if [ "x$WIFITYPE" != "x$WIFITYPE_EXTRA" ] && [ "x$WIFITYPE" != "x$WIFITYPE_ATH" ] && [ "x$WIFITYPE" != "x$WIFITYPE_ATH2" ]; then
		    WIFITYPE=$WIFITYPE_EXTRA
		  fi
#TODO: don't force to use extra encap		  
		  WIFITYPE=$WIFITYPE_EXTRA
		else
		  #read wificonfig for aifs, cwmin etc.
		  #Hint: already done
		  #but overwrite wifitype, since ns2 only support wifiextra
		  WIFITYPE=$WIFITYPE_EXTRA
		fi
		
		CPPOPTS=""
		
		#echo "DUMP: $DUMPFILEDIR" >> $RESULTDIR/debug.txt
		if [ "x$DUMPFILEDIR" != "x" ]; then
		  if  [ -e $PWD/$DUMPFILEDIR ]; then
		    DUMPFILEDIR=$PWD/$DUMPFILEDIR
		  fi
		  DUMPFILESRC="$DUMPFILEDIR/$CNODE.$CDEV.raw.dump"
		  #echo "SRC: $DUMPFILESRC" >> $RESULTDIR/debug.txt
		  if [ -e $DUMPFILESRC ]; then
		    WIFITYPE=`test_header.sh $DUMPFILESRC`
		    #echo "WIFI: $WIFITYPE" >> $RESULTDIR/debug.txt
		    CPPOPTS="$CPPOPTS -DDUMPDEVICE -DDUMPFILESRC=\"$DUMPFILESRC\""
		    #echo "CPPOPTS: $CPPOPTS" >> $RESULTDIR/debug.txt
		  fi
		fi
		
                . $DIR/../../nodes/etc/wifi/default
                if [ "x$CWMIN" = "x" ]; then
                  CWMIN=$DEFAULT_CWMIN
                fi
	        if [ "x$CWMAX" = "x" ]; then
	          CWMAX=$DEFAULT_CWMAX
	        fi
	        if [ "x$AIFS" = "x" ]; then
	          AIFS=$DEFAULT_AIFS
	        fi
	
		AIFS=`echo $AIFS | sed "s# #\\\\ #g"`
		CWMIN=`echo $CWMIN | sed "s# #\\\\ #g"`
		CWMAX=`echo $CWMAX | sed "s# #\\\\ #g"`
		
                CPPOPTS="$CPPOPTS -DNODENAME=$CNODE -DNODEDEVICE=$CDEV -DTIME=$TIME"
                CPPOPTS="$CPPOPTS -DDEBUGLEVEL=$DEBUG"
                CPPOPTS="$CPPOPTS -DSIMULATION"
                CPPOPTS="$CPPOPTS -DWIFITYPE=$WIFITYPE"
		
		if [ "x$USED_SIMULATOR" = "xns" ] && [ "x$GUICONNECTOR" = "xyes" ]; then
		  CPPOPTS="$CPPOPTS -DGUICONNECTOR" 
		fi 
			
		NODEID_INC=`(cd $CONFIGDIR; cat $CLICK | grep -v "^//" | grep "BRN2NodeIdentity" | wc -l)`
		
		if [ $NODEID_INC -gt 0 ]; then
		     CPPOPTS="$CPPOPTS -DNODEID_NAME"
		fi

		#CPPOPTS="$CPPOPTS -DCWMINPARAM=\"$CWMIN\""#-DCWMAXPARAM=\\\"$CWMAX\\\" -DAIFSPARAM=\\\"$AIFS\\\""
		#echo $CPPOPTS
		
		HAS_BRNINCLUDE=`cat $CLICK | grep '#include "brn/helper.inc"' | wc -l`

                ( cd $CONFIGDIR; cat $CLICK | add_include $HAS_BRNINCLUDE | cpp -I$DIR/../../measurement/etc/click $CPPOPTS -DCWMINPARAM="\"$CWMIN\"" -DCWMAXPARAM="\"$CWMAX\"" -DAIFSPARAM="\"$AIFS\"" | sed -e "s#NODEDEVICE#$CDEV#g" -e"s#NODENAME#$CNODE#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" | grep -v "^#" > $CLICKFINALNAME )

              else
                CLICKFINALNAME="-"
              fi
            else
              CLICKFINALNAME="-"
            fi
            
            echo "$CNODE $CDEV $CMODDIR $CMODOPT $WIFICONFIG $CCMODDIR $CLICKFINALNAME $CCLOG $CAPP $CAPPL" | sed -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" >> $RESULTDIR/$NODETABLE.$POSTFIX

          done
      fi
		done < $CONFIGDIR/$NODETABLE
		;;
	"cleanup")
		echo "Not supported"
		;;
	*)
		$0 help
		;;
esac

exit 0		
