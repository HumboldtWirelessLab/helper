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

#Function used to get params for control part TODO: try to use arrays
function get_params() {
  shift 6
  echo $@
}

AC_TIME=0
NODEMAC_SEDARG=""

while read line; do
  NODENAME=`echo $line | awk '{print $1}'`
  NODEMAC=`echo $line | awk '{print $3}'`
  NODEMAC_SEDARG="$NODEMAC_SEDARG -e s#$NODENAME:eth#$NODEMAC#g"

done < $2

while read line; do
  ISCOMMENT=`echo $line | grep "#" | wc -l`
  if [ $ISCOMMENT -eq 0 ]; then
    TIME=`echo $line | awk '{print $1}'`
    NODENAME=`echo $line | awk '{print $2}'`
    NODEDEVICE=`echo $line | awk '{print $3}'`
    MODE=`echo $line | awk '{print $4}'`
    ELEMENT=`echo $line | awk '{print $5}'`
    HANDLER=`echo $line | awk '{print $6}'`
    NODENUM=`cat $2 | egrep "^$NODENAME[[:space:]]" | awk '{print $4}'`
    if [ "x$MODE" = "xwrite" ]; then
      VALUE=`get_params $line | sed $NODEMAC_SEDARG`
    fi

    if [ "x$TIME" != "x" ]; then
      DIFF_TIME=`expr $TIME - $AC_TIME`
      sleep $DIFF_TIME

      if [ "x$MODE" = "xwrite" ]; then
        #echo "clickctrl.sh write $NODENAME 7777 $ELEMENT $HANDLER \"$VALUE\""
        $DIR/clickctrl.sh write $NODENAME 7777 $ELEMENT $HANDLER "$VALUE"
      else
        #echo "clickctrl.sh read $NODENAME 7777 $ELEMENT $HANDLER" >&2
        VERSION="java" $DIR/clickctrl.sh read $NODENAME 7777 $ELEMENT $HANDLER
      fi
      AC_TIME=$TIME
    fi
  fi
done < $1

exit 0
