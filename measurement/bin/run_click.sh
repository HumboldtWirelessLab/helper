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

if [ "x$2" = "xprint" ]; then
  cpp -I$DIR/../etc/click/ $1 | grep -v "#"
else
  cpp -I$DIR/../etc/click/ $1 | grep -v "#" | click
fi
