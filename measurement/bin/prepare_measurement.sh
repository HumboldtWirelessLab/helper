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

case "$1" in
	"help")
		echo "Use $0 prepare | cleanup"
		echo "Tool wich prepares the final skripts for a measurement (run_single_measurement). Replaces Variables ind the skript (like NODENAME, NODEDEVICE, ...)"
		;;
	"prepare")
		SIMDIS=$2
		. $SIMDIS
		NODELIST=`cat $NODETABLE | grep -v "#" | awk '{print $1}' | sort -u`
		NODECOUNT=`cat $NODETABLE | grep -v "#" | wc -l`

		#Prepare click
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do		    
			CLICK=`cat $NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $7}'`
			WIFICONFIG=`cat $NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`

			if [ ! "x$WIFICONFIG" = "x" ] && [ ! "x$WIFICONFIG" = "x-" ]; then
			    if [ -f  $DIR/../../nodes/etc/wifi/$WIFICONFIG ]; then                                                                                                                                                   
				. $DIR/../../nodes/etc/wifi/$WIFICONFIG
			    else
				. $WIFICONFIG
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
			fi
			
			if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
			    CLICK=`echo $CLICK | sed -e "s#WORKDIR#$WORKDIR#g"`
			    
			    if [ -e $CLICK ]; then
				cat $CLICK | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAP#g" -e "s#TODEVICE#WIFIENCAP -> TORAWDEVICE#g" | sed -e "s#WIFIDECAP#$WIFIDECAP#g" -e "s#WIFIENCAP#$WIFIENCAP#g" -e "s#FROMRAWDEVICE#FromDevice(NODEDEVICE)#g" -e "s#TORAWDEVICE#ToDevice(NODEDEVICE)#g" | sed -e "s#NODEDEVICE#$nodedevice#g" -e "s#NODENAME#$node#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" > $CLICK.$node.$nodedevice
			    fi
			fi
			
		    done
		done
		
		cat $NODETABLE | grep -v "#" | awk '{ print $1" "$2" "$3" "$4" "$5" "$6" "$7"."$1"."$2" "$8" "$9" "$10}' | sed -e "s#[[:space:]]*-\.*[[:alnum:]\.]*# -#g" -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$WORKDIR#g" > $NODETABLE.$POSTFIX
		cat $SIMDIS | sed "s#$NODETABLE#$NODETABLE.$POSTFIX#g" | sed -e "s#WORKDIR#$WORKDIR#g" > $SIMDIS.$POSTFIX
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
