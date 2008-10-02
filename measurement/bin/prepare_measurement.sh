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
		NODELIST=`cat $CONFIGDIR/$NODETABLE | grep -v "#" | awk '{print $1}' | sort -u`
		NODECOUNT=`cat $CONFIGDIR/$NODETABLE | grep -v "#" | wc -l`

		#Prepare click
		for node in $NODELIST; do
		    NODEDEVICELIST=`cat $CONFIGDIR/$NODETABLE | egrep "^$node[[:space:]]" | awk '{print $2}'`
		    for nodedevice in $NODEDEVICELIST; do		    
			CLICK=`cat $CONFIGDIR/$NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $7}'`
			WIFICONFIG=`cat $CONFIGDIR/$NODETABLE | grep -v "#" | egrep "^$node[[:space:]]" | egrep "[[:space:]]$nodedevice[[:space:]]" | awk '{print $5}'`

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
			
			echo "$CLICK"
			
			if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
			    CLICK=`echo $CLICK | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`
			    
			    if [ -e $CLICK ] || [ -e $CONFIGDIR/$CLICK ]; then
				CLICKBASENAME=`basename $CLICK`
				( cd $CONFIGDIR; cat $CLICK | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAP#g" -e "s#TODEVICE#WIFIENCAP -> TORAWDEVICE#g" | sed -e "s#WIFIDECAP#$WIFIDECAP#g" -e "s#WIFIENCAP#$WIFIENCAP#g" -e "s#FROMRAWDEVICE#FromDevice(NODEDEVICE)#g" -e "s#TORAWDEVICE#ToDevice(NODEDEVICE)#g" | sed -e "s#NODEDEVICE#$nodedevice#g" -e "s#NODENAME#$node#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $RESULTDIR/$CLICKBASENAME.$node.$nodedevice )
			    fi
			fi
			
		    done
		done

		SIMDISBASENAME=`basename $SIMDIS`
		cat $CONFIGDIR/$NODETABLE | grep -v "#" | awk '{ print $1" "$2" "$3" "$4" "$5" "$6" WORKDIR/"$7"."$1"."$2" "$8" "$9" "$10}' | sed -e "s#[[:space:]]*-\.*[[:alnum:]\.]*# -#g" -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" > $RESULTDIR/$NODETABLE.$POSTFIX
		cat $SIMDIS | sed "s#$NODETABLE#$NODETABLE.$POSTFIX#g" | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $RESULTDIR/$SIMDISBASENAME.$POSTFIX
		
		;;
	*)
		$0 help
		;;
esac

exit 0
