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

add_include() {
  echo "#include \"brn/helper.inc\""
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

if [ "$USED_SIMULATOR" != "jist" ] && [ "$USED_SIMULATOR" != "ns" ]; then
  echo "USED_SIMULATOR is unknown ($USED_SIMUALTOR). Use ns or jist."
  exit 0
fi

echo "sim is $USED_SIMULATOR"

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
		        CNODES=`cat $CONFIGDIR/$GROUP | grep -v "#"`
		        #echo "NODES: $CNODE"
		      else
        		CNODES=$CNODE
        	      fi
																		     
		      for CNODE in $CNODES; do

		        if [ "x$USED_SIMULATOR" = "xns" ]; then
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
	
	        if [ "x$USED_SIMULATOR" = "xjist" ]; then	
		  #echo "$WIFICONFIG"
	          if [ ! -f $WIFICONFIG ]; then
		    if [ -f $DIR/../../nodes/etc/wifi/$WIFICONFIG ]; then
		      WIFICONFIG="$DIR/../../nodes/etc/wifi/$WIFICONFIG"
		    else
		      WIFICONFIG="$DIR/../../nodes/etc/wifi/monitor.default"
		    fi
		  fi
																			    
		  . $WIFICONFIG
		  cp $WIFICONFIG $RESULTDIR
		  
		  if [ "x$WIFITYPE" = "x" ]; then
		    WIFITYPE=806
		  fi
		else
		  WIFITYPE=806
		fi																		      
              
                CPPOPTS="-DNODENAME=$CNODE -DNODEDEVICE=$CDEV -DTIME=$TIME"
                CPPOPTS="$CPPOPTS -DDEBUGLEVEL=$DEBUG"
                CPPOPTS="$CPPOPTS -DSIMULATION"
                CPPOPTS="$CPPOPTS -DWIFITYPE=$WIFITYPE"
		
		NODEID_INC=`(cd $CONFIGDIR; cat $CLICK | grep -v "^//" | grep "BRN2NodeIdentity" | wc -l)`
		
		if [ $NODEID_INC -gt 0 ]; then
		     CPPOPTS="$CPPOPTS -DNODEID_NAME"
		fi

                ( cd $CONFIGDIR; cat $CLICK | add_include | cpp -I$DIR/../../measurement/etc/click $CPPOPTS | sed -e "s#NODEDEVICE#$CDEV#g" -e"s#NODENAME#$CNODE#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" | grep -v "^#" > $CLICKFINALNAME )
                
                if [ "x$HANDLERSCRIPT" != "x" ]; then
                  ( cd $CONFIGDIR; $DIR/../../measurement/bin/handle_script.sh $HANDLERSCRIPT $CNODE >> $CLICKFINALNAME )
                fi
                
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
