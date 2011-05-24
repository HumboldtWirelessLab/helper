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

if [ "x$1" = "x" ] ; then
  FILE=db
else
  FILE=$1
fi

if [ "x$FILE" = "xdb" ]; then
  echo "Use db. Get Unused nodes ...."
  #TODO: use file to determinate, which node needs the driver!
  NODES=`$DIR/../../host/lib/sql/get_unused_nodes.pl | grep -v seismo`
  echo $NODES
  for CNODE in $NODES; do
    echo -n "$CNODE "
    NODELIST="$CNODE" $DIR/../../host/bin/environment.sh mount
    NODEDEVICES=`ssh root@$CNODE "PATH=/bin/:/sbin/:/usr/bin:/usr/sbin/; iwconfig 2> /dev/null" | grep "IEEE" | awk '{print $1}'`
    for d in $NODEDEVICES; do
      echo -n "$d "
      NODE=$CNODE DEVICES=$d $DIR/../../host/bin/wlandevices.sh delete
    done

    NODELIST="$CNODE" MODULSDIR=$DIR/../../nodes/lib/modules/NODEARCH/KERNELVERSION $DIR/../../host/bin/wlanmodules.sh rmmod
    echo "rmmod"
  done

else
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

  done < $FILE

fi

exit 0
