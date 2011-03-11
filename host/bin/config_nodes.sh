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

. $DIR/functions.sh

if [ "x$1" = "x" ]; then
    echo "Use $0 nodefile command [args]"
    exit 0
fi


NODELIST=`cat $1 | grep -v "^#"`

case "$2" in
  "channel")
        NODELIST=$NODELIST $DIR/run_on_nodes.sh "/usr/sbin/iwconfig ath0 channel $3"
        ;;
  "power")
        NODELIST=$NODELIST $DIR/run_on_nodes.sh "/usr/sbin/iwconfig ath0 txpower $3"
        ;;
  "iwconfig")
        NODELIST=$NODELIST $DIR/run_on_nodes.sh "/usr/sbin/iwconfig"
        ;;
  ".")
        DIR=$pwd/$dir
        ;;
   *)
        echo "Error while getting directory"
        exit -1
        ;;
esac
