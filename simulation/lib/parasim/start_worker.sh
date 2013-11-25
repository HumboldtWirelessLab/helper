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

. $DIR/config

if [ "x$1" = "x" ]; then
  echo "Missing params"
  exit 0
fi

#PARAMS: name id

(nohup $DIR/worker.sh $1 $2 > /dev/null 2>&1  < /dev/null) &

exit 0

