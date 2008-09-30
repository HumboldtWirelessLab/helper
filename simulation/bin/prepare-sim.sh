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
