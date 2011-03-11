#!/bin/bash

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

AVAILABLECHANNELS=" 1 2 3 4 5 6 7 8 9 10 11 12 13 36 40 44 48 52 56 60 64 100 104 108 112 116 120 124 128 132 136 140 "

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

$DIR/sync_dumps.sh $1

case "$1" in
  "prestart")
    echo "prestart"
    killall update_gps.sh 2>&1
    killall channel_hopping.sh 2>&1
    ;;
  "start")
    echo "Start"
    MAXGPSTRY=$MAXGPSTRY $DIR/update_gps.sh &
    $DIR/channel_hopping.sh &
    ;;
  "stop")
    echo "stop"
    killall update_gps.sh 2>&1
    killall channel_hopping.sh 2>&1
    ;;
  "poststop")
    echo "poststop"
    ;;
esac

