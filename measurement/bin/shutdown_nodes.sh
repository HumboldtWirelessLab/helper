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

if [ "x$WORKDIR" = "x" ]; then
    WORKDIR=$pwd
fi

BASEDIR=$DIR/../../

WORKDIR=$pwd
CONFIGDIR=$(dirname "$1")
SIGN=`echo $CONFIGDIR | cut -b 1`

case "$SIGN" in
  "/")
      ;;
  ".")
      CONFIGDIR=$WORKDIR/$CONFIGDIR
      ;;
   *)
      CONFIGDIR=$WORKDIR/$CONFIGDIR
      ;;
esac

while read line; do
	ISCOMMENT=`echo $line | grep "#" | wc -l`
	NOSPACELINE=`echo $line | sed -e "s#[[:space:]]##g"`

	if [ ! "x$NOSPACELINE" = "x" ]; then
		if [ $ISCOMMENT -eq 0 ]; then

			#read CNODE CDEV CMODDIR CMODOPT WIFICONFIG CCMODDIR CLICK CCLOG CAPP CAPPL <<< $line
			CNODE=`echo $line | awk '{print $1}'`
			CDEV=`echo $line | awk '{print $2}'`
			CMODDIR=`echo $line | awk '{print $3}' | sed -e "s#BASEDIR#$BASEDIR#g"`

			ISGROUP=`echo $CNODE | grep "group:" | wc -l`

			if [ "x$ISGROUP" = "x1" ]; then
				GROUP=`echo $CNODE | sed "s#group:##g"`
				CNODES=`cat $CONFIGDIR/$GROUP | grep -v "#"`
				#echo "NODES: $CNODE"
			else
				CNODES=$CNODE
			fi

			for CNODE in $CNODES; do
				echo "$CNODE $CDEV $CMODDIR"  
                                NODELIST="$CNODE" $DIR/../../host/bin/environment.sh mount 
				NODE=$CNODE DEVICES=$CDEV $DIR/../../host/bin/wlandevices.sh delete
                                NODELIST="$CNODE" MODULSDIR=$CMODDIR $DIR/../../host/bin/wlanmodules.sh rmmod
			done
		fi
	fi

done < $1

exit 0