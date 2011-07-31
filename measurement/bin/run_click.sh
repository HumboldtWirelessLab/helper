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
  if [ "x$VALGRIND" = "x1" ]; then
    cpp -I$DIR/../etc/click/ $1 | grep -v "#" | valgrind --leak-check=full --leak-resolution=high --leak-check=full --show-reachable=yes --log-file=valgrind.log `which click` > out.log  2>&1
  else
    cpp -I$DIR/../etc/click/ $1 | grep -v "#" | click
  fi
fi
