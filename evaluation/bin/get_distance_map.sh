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

function mac_to_num() {
  NODEMAC_SEDARG=""

  if [ "x$1" != "x" ]; then
    while read line; do
      NODENAME=`echo $line | awk '{print $1}'`
      NODEMAC=`echo $line | awk '{print $3}'`
      NODENUM=`echo $line | awk '{print $4}'`
      NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#$NODEMAC#$NODENUM#g -e s#$NODENAME#$NODENUM#g"
    done < $1
  fi

# echo $NODEMAC_SEDARG >&2

  sed $NODEMAC_SEDARG
}


NODE_1=`cat $1 | grep -v "#" | awk '{print $1}' | sort -u`
NODE_2=`cat $1 | grep -v "#" | awk '{print $1}' | sort -u`

for n in $NODE_1; do
  for m in $NODE_2; do
    if [ "x$n" != "x$m" ]; then
      #echo "foo"
      ( cd $DIR/../lib/distance/; ./relative_distance.pl $n $m ) | mac_to_num $1
    fi
  done
done

exit 0

