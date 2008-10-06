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
    POSTFIX="simulation"
fi

if [ "x$WORKDIR" = "x" ]; then
    WORKDIR=$pwd
fi

BASEDIR=$DIR/../../

case "$1" in
	"help")
		echo "Use $0 run"
		;;
	"prepare")
		SIMDIS=$2
		. $SIMDIS
		
				echo -n "" > $RESULTDIR/$NODETABLE.$POSTFIX
		while read line; do
		    ISCOMMENT=`echo $line | grep "#" | wc -l`
		    if [ $ISCOMMENT -eq 0 ]; then
			read CNODE CDEV CMODDIR CMODOPT WIFICONFIG CCMODDIR CLICK CCLOG CAPP CAPPL <<< $line
			
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
				    WIFIENCAP="AthdescEncap()"
				    WIFIDECAP="AthdescDecap()"
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
				( cd $CONFIGDIR; cat $CLICK | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAP#g" -e "s#TODEVICE#WIFIENCAP -> TORAWDEVICE#g" | sed -e "s#WIFIDECAP#$WIFIDECAP#g" -e "s#WIFIENCAP#$WIFIENCAP#g" -e "s#FROMRAWDEVICE#FromDevice(NODEDEVICE)#g" -e "s#TORAWDEVICE#ToDevice(NODEDEVICE)#g" | sed -e "s#NODEDEVICE#$CDEV#g" -e "s#NODENAME#$CNODE#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $CLICKFINALNAME )
			    else
				CLICKFINALNAME="-"
			    fi
			else
			    CLICKFINALNAME="-"
			fi
			
			echo "$CNODE $CDEV $CMODDIR $CMODOPT $WIFICONFIG $CCMODDIR $CLICKFINALNAME $CCLOG $CAPP $CAPPL" | sed -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" >> $RESULTDIR/$NODETABLE.$POSTFIX

		    fi
		done < $CONFIGDIR/$NODETABLE




		NODELIST=`cat $NODETABLE | grep -v "#" | awk '{print $1}' | sort -u`
		NODECOUNT=`cat $NODETABLE | grep -v "#" | wc -l`
		#Prepare click
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do
			CLICK=`cat $NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $7}' | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g"`
			cat $CLICK | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAP#g" -e "s#TODEVICE#WIFIENCAP -> TORAWDEVICE#g" -e "s#FROMRAWDEVICE#FromSimDevice(NODEDEVICE,4096)#g" -e "s#WIFIDECAP#Strip(14)#g" -e "s#TORAWDEVICE#ToSimDevice(NODEDEVICE)#g" -e "s#WIFIENCAP#AddEtherNsclick()#g" | sed -e "s#NODEDEVICE#eth0#g" -e"s#NODENAME#$node#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $CLICK.$node.$nodedevice
		    done
		done
		
		cat $NODETABLE | grep -v "#" | awk '{ print $1" "$2" "$3" "$4" "$5" "$6" "$7"."$1"."$2" "$8" "$9" "$10}' | sed -e "s#LOGDIR#$LOGDIR#g"  -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $NODETABLE.$POSTFIX
		cat $SIMDIS | sed -e "s#$NODETABLE#$NODETABLE.$POSTFIX#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $SIMDIS.$POSTFIX
		;;
	"cleanup")
		SIMDIS=$2
		. $SIMDIS
		cat $NODETABLE.$POSTFIX |  grep -v "#" | awk '{print $7}' | xargs rm -f
		rm -f $SIMDIS.$POSTFIX
		rm -f $NODETABLE.$POSTFIX
		;;
	*)
		$0 help
		;;
esac

exit 0		
