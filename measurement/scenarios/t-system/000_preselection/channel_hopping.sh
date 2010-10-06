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

. $DIR/config

if [ $HOPPINGDURATION = 0 ]; then
  exit 0
fi

sleep 10

while [ true ]; do
  for c in $HOPPINGCHANNELS; do
    NODELIST="localhost" $DIR/../../../../host/bin/run_on_nodes.sh "iwconfig $HOPPINGDEVICE channel $c"
    sleep $HOPPINGDURATION
  done
done

