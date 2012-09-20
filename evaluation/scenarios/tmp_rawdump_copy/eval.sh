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

. $CONFIGFILE

#echo $RESULTDIR
#(cd $RESULTDIR;ls *.dump)

if [ -f $RESULTDIR/nodes.mac ]; then

  NODES=`cat $RESULTDIR/nodes.mac | awk '{print $1}'`
  
  for NODE in $NODES; do
    DEVICES=`cat $RESULTDIR/nodes.mac | grep "$NODE " | awk '{print $2}'`
    for DEVICE in $DEVICES; do

    if [ ! -f $RESULTDIR/$NODE.$DEVICE.raw.dump ]; then
      if [ "x$MODE" = "xsim" ]; then
        if [ -f /tmp/$NODE.$DEVICE.raw.dump ]; then
          echo "/tmp/$NODE.$DEVICE.raw.dump"
          mv /tmp/$NODE.$DEVICE.raw.dump $RESULTDIR
        fi
      else
        scp -i $DIR/../../../host/etc/keys/id_dsa root@$NODE:/tmp/$NODE.$DEVICE.raw.dump $RESULTDIR > /dev/null 2>&1
        ssh -i $DIR/../../../host/etc/keys/id_dsa root@$NODE "/bin/rm -f /tmp/$NODE.$DEVICE.raw.dump"
      fi
    fi
  done
  done

fi

exit 0

