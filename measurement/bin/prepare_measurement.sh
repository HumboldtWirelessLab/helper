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
		cat $SIMDIS | sed "s#$NODETABLE#$NODETABLE.$POSTFIX#g" | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $RESULTDIR/$SIMDISBASENAME.$POSTFIX

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

			    if [ ! "x$WIFICONFIG" = "x" ] && [ ! "x$WIFICONFIG" = "x-" ]; then
				if [ -f  $DIR/../../nodes/etc/wifi/$WIFICONFIG ]; then                                                                                                                                                   
				    . $DIR/../../nodes/etc/wifi/$WIFICONFIG
				    WIFICONFIGFINALNAME="$DIR/../../nodes/etc/wifi/$WIFICONFIG"
				else
				    if [ -f  $CONFIG/$WIFICONFIG ]; then                                                                                                                                                   
					. $CONFIG/$WIFICONFIG
					WIFICONFIGFINALNAME=$CONFIG/$WIFICONFIG
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
						
				case "$WIFITYPE" in
				    "801")
					WIFIENCAP="Null()"
					WIFIDECAP="Null()"
					;;
				    "802")
					WIFIENCAP="RadiotapEncap()"
					WIFIDECAP="RadiotapDecap()"
					;;
				    "803")
					WIFIENCAP="Prism2Encap()"
					WIFIDECAP="Prism2Decap()"
					;;
				    "804")
					WIFIENCAP="AthdescEncap()"
					WIFIDECAP="AthdescDecap()"
					;;
				    "805")
					WIFIENCAP="Ath2Encap(ATHENCAP true)"
					WIFIDECAP="Ath2Decap(ATHDECAP true)"
					;;
			    	    *)
					WIFIENCAP="Null()"
					WIFIDECAP="Null()"
					;;
				esac
			    else
				WIFICONFIGFINALNAME="-"
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

				    ( cd $CONFIGDIR; cat $CLICK | sed -e "s#//[0-$DEBUG]/##g" -e "s#/\*[0-$DEBUG]/##g" -e "s#/[0-$DEBUG]\*/##g" -e "s#DEBUGLEVEL#$DEBUG#g" | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAPTMPL#g" -e "s#TODEVICE#WIFIENCAPTMPL -> TORAWDEVICE#g" | sed -e "s#WIFIDECAPTMPL#$WIFIDECAP#g" -e "s#WIFIENCAPTMPL#$WIFIENCAP#g" -e "s#FROMRAWDEVICE#FromDevice(NODEDEVICE, PROMISC true, OUTBOUND true)#g" -e "s#TORAWDEVICE#ToDevice(NODEDEVICE)#g" | sed -e "s#NODEDEVICE#$CDEV#g" -e "s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $CLICKFINALNAME )
				    
				    echo "Script(wait $TIME, stop);" >> $CLICKFINALNAME
				    
				    if [ "$CCMODDIR" = "-" ] || [ "x$CLICKMODE" != "xkernel" ]; then
				      if [ "x$CONTROLSOCKET" != "xno" ]; then
				        echo "ControlSocket(tcp, 7777);" >> $CLICKFINALNAME
				      fi
				    fi
				    
				else
				    CLICKFINALNAME="-"
				fi
			    else
				CLICKFINALNAME="-"
			    fi
			
			    echo "$CNODE $CDEV $CMODDIR $CMODOPT $WIFICONFIG $CCMODDIR $CLICKFINALNAME $CCLOG $CAPP $CAPPL" | sed -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" >> $RESULTDIR/$NODETABLE.$POSTFIX

			fi
		    fi
		done < $CONFIGDIR/$NODETABLE
				
		;;
	*)
		$0 help
		;;
esac

exit 0
