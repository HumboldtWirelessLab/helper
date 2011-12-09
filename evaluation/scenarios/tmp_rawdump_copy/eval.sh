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

  while read line; do
    NODE=`echo $line | awk '{print $1}'`
    DEVICE=`echo $line | awk '{print $2}'`
    
    if [ -f /tmp/$NODE.$DEVICE.raw.dump ]; then
      echo "/tmp/$NODE.$DEVICE.raw.dump"
      mv /tmp/$NODE.$DEVICE.raw.dump $RESULTDIR
    fi
  done < $RESULTDIR/nodes.mac
      
fi

exit 0

