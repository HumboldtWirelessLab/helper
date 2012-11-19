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

for node in $NODELIST; do
  scp -i $DIR/../etc/keys/id_dsa -F $DIR/../etc/keys/ssh_config root@$node:$1 $2
done
