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
    NODENAME=`echo $line | awk '{print $4}'`
    NODEMAC=`echo $line | awk '{print $3}'`
    NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#$NODEMAC#$NODENAME#g"
  done < $FILE
fi

sed $NODEMAC_SEDARG
