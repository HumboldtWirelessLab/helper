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

case "$1" in
	"help")
		echo "Use $0 run"
		;;
	"prepare")
		SIMDIS=$2
		. $SIMDIS
		NODELIST=`cat $NODETABLE | grep -v "#" | awk '{print $1}' | sort -u`
		NODECOUNT=`cat $NODETABLE | grep -v "#" | wc -l`

		#Prepare click
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $NODETABLE | grep "^$node" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do		    
			CLICK=`cat $NODETABLE | grep -v "#" | grep $node | grep $nodedevice | awk '{print $5}'`
			WIFICONFIG=`cat $NODETABLE | grep -v "#" | grep $node | grep $nodedevice | awk '{print $4}'`
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
			
			cat $CLICK | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> $WIFIDECAP#g" -e "s#TODEVICE#$WIFIENCAP -> TORAWDEVICE#g" | sed -e "s#FROMRAWDEVICE#FromDevice(DEVICE)#g" -e "s#TORAWDEVICE#ToDevice(DEVICE)#g" | sed -e "s#DEVICE#$nodedevice#g" -e "s#NODE#$node#g" | sed -e "s#RUNTIME#$TIME#g" > $CLICK.$node.$nodedevice

		    done
		done
		
		cat $NODETABLE | grep -v "#" | awk '{ print $1" "$2" "$3" "$4" "$5"."$1"."$2" "$6}' | sed -e "s#LOGDIR#$LOGDIR#g" > $NODETABLE.$POSTFIX
		cat $SIMDIS | sed "s#$NODETABLE#$NODETABLE.$POSTFIX#g" > $SIMDIS.$POSTFIX
		;;
	"cleanup")
		SIMDIS=$2
		. $SIMDIS
		cat $NODETABLE.$POSTFIX |  grep -v "#" | awk '{print $5}' | xargs rm -f
		rm -f $SIMDIS.$POSTFIX
		rm -f $NODETABLE.$POSTFIX
		;;
	*)
		$0 help
		;;
esac

exit 0
