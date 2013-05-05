#!/bin/bash

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


if [ "x$1" != "x" ]; then
  FILE=$1
else
  if [ -f $PWD/nodes.mac ]; then
    FILE=$pwd/nodes.mac
  else
    if [ -f $dir/../etc/nodes.mac ]; then
      FILE=$dir/../etc/nodes.mac
    else
      FILE=""
    fi
  fi
fi

if [ "x$FILE" != "x" ]; then
  while read line; do
    NODENAME=`echo $line | awk '{print $1}'`
    NODEMAC=`echo $line | awk '{print $3}'`
    NODENUM=`echo $line | awk '{print $4}'`
    NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#$NODEMAC#$NODENAME#g"
    NODEMAC2NUM_SEDARG="$NODEMAC2NUM_SEDARG -e s#$NODEMAC#$NODENUM#g"
  done < $FILE
fi

if [ "x$MAC2NUM" = "x1" ]; then
  sed $NODEMAC2NUM_SEDARG
else
  sed $NODEMAC_SEDARG
fi
