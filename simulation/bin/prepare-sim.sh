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

BASEDIR=$DIR/../../

case "$1" in
	"help")
		echo "Use $0 run"
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
			
			if [ ! "x$CLICK" = "x" ] && [ ! "x$CLICK" = "x-" ]; then
			    CLICK=`echo $CLICK | sed -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g"`
			    
			    if [ -e $CLICK ] || [ -e $CONFIGDIR/$CLICK ]; then
				CLICKBASENAME=`basename $CLICK`
				CLICKFINALNAME="$RESULTDIR/$CLICKBASENAME.$CNODE.$CDEV"
				( cd $CONFIGDIR; cat $CLICK | sed -e "s#FROMDEVICE#FROMRAWDEVICE -> WIFIDECAP#g" -e "s#TODEVICE#WIFIENCAP -> TORAWDEVICE#g" -e "s#FROMRAWDEVICE#FromSimDevice(NODEDEVICE,4096)#g" -e "s#WIFIDECAP#Strip(14)#g" -e "s#TORAWDEVICE#ToSimDevice(NODEDEVICE)#g" -e "s#WIFIENCAP#AddEtherNsclick()#g" | sed -e "s#NODEDEVICE#eth0#g" -e"s#NODENAME#$node#g" -e "s#RUNTIME#$TIME#g" -e "s#RESULTDIR#$RESULTDIR#g" -e "s#WORKDIR#$WORKDIR#g" -e "s#BASEDIR#$BASEDIR#g" > $CLICKFINALNAME )
			    else
				CLICKFINALNAME="-"
			    fi
			else
			    CLICKFINALNAME="-"
			fi
			
			echo "$CNODE $CDEV $CMODDIR $CMODOPT $WIFICONFIG $CCMODDIR $CLICKFINALNAME $CCLOG $CAPP $CAPPL" | sed -e "s#LOGDIR#$LOGDIR#g" | sed -e "s#WORKDIR#$RESULTDIR#g" -e "s#BASEDIR#$BASEDIR#g" -e "s#CONFIGDIR#$CONFIGDIR#g" >> $RESULTDIR/$NODETABLE.$POSTFIX

		    fi
		done < $CONFIGDIR/$NODETABLE
		;;
	"cleanup")
#		SIMDIS=$2
#		. $SIMDIS
#		cat $NODETABLE.$POSTFIX |  grep -v "#" | awk '{print $7}' | xargs rm -f
#		rm -f $SIMDIS.$POSTFIX
#		rm -f $NODETABLE.$POSTFIX
		;;
	*)
		$0 help
		;;
esac

exit 0		
