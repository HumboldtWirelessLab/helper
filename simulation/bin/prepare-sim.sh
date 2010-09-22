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
    POSTFIX="simulation"
fi

BASEDIR=$DIR/../../

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

                        #TODO: replace eth0 by CDEV
		        NODEINFILE=`cat $RESULTDIR/$NODETABLE.$POSTFIX | grep -e "^$CNODE[[:space:]]*eth0" | wc -l`
			
                        if [ $NODEINFILE -ne 0 ]; then
			  #echo "Found node $CNODE with device $CDEV. Step over"  
			  continue
			fi
		      
		        CDEV=eth0
		        
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
				
#				  ( cd $CONFIGDIR; cat $CLICK | sed -e "s#//[0-$DEBUG]/##g" -e "s#/\*[0-$DEBUG]/##g" -e "s#/[0-$DEBUG]\*/##g" -e "s#DEBUGLEVEL#$DEBUG#g" | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAPTMPL#g" -e "s#TODEVICE#WIFIENCAPTMPL -> TORAWDEVICE#g" -e "s#FROMRAWDEVICE#FromSimDevice(NODEDEVICE,4096)#g" -e "s#WIFIDECAPTMPL#Strip(14)#g" -e "s#TORAWDEVICE#ToSimDevice(NODEDEVICE)#g" -e "s#WIFIENCAPTMPL#AddEtherNsclick()#g" | sed -e "s#NODEDEVICE#$CDEV#g" -e"s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#TODUMP#ToDump#g" > $CLICKFINALNAME )
				  ( cd $CONFIGDIR; cat $CLICK | sed -e "s#//[0-$DEBUG]/##g" -e "s#/\*[0-$DEBUG]/##g" -e "s#/[0-$DEBUG]\*/##g" -e "s#DEBUGLEVEL#$DEBUG#g" | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAPTMPL#g" -e "s#TODEVICE#WIFIENCAPTMPL -> TORAWDEVICE#g" -e "s#FROMRAWDEVICE#FromSimDevice(NODEDEVICE,4096)#g" -e "s#WIFIDECAPTMPL#ExtraDecap()#g" -e "s#TORAWDEVICE#ToSimDevice(NODEDEVICE)#g" -e "s#WIFIENCAPTMPL#ExtraEncap()#g" | sed -e "s#NODEDEVICE#$CDEV#g" -e"s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#TODUMP#ToDump#g" > $CLICKFINALNAME )
				  ( cd $CONFIGDIR; echo "Script( wait $TIME.001, stop);" >> $CLICKFINALNAME )
				  
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
