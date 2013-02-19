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

if [ "x$COMPRESSION" = "xyes" ]; then
  COMPRESSION=""
#  echo "Compression in TH"  >> $pwd/foo
#cat $DIR/../etc/click/oracle.click | sed -e "s#DUMP#$1#g" -e "s#//COMPRESSION#$COMPRESSION#g" > foo.comp
else
  COMPRESSION="//"
#  echo "No Compression in TH" >> $pwd/foo
#cat $DIR/../etc/click/oracle.click | sed -e "s#DUMP#$1#g" -e "s#//COMPRESSION#$COMPRESSION#g" > foo.nocomp
fi

if [ "x$DEBUG" = "x1" ]; then
  echo "DEBUG=1"
  cat $DIR/../etc/click/oracle.click | sed -e "s#DUMP#$1#g" -e "s#//COMPRESSION#$COMPRESSION#g" | click-align
  cat $DIR/../etc/click/oracle.click | sed -e "s#DUMP#$1#g" -e "s#//COMPRESSION#$COMPRESSION#g" | click-align 2> /dev/null | click 2>&1
  exit 0
fi

RESULT=`cat $DIR/../etc/click/oracle.click | sed -e "s#DUMP#$1#g" -e "s#//COMPRESSION#$COMPRESSION#g" | click-align 2> /dev/null | click 2>&1 | grep -v "expensive"`

PACKETS=`echo "$RESULT" | grep -v ":"`
HANDLER=`echo "$RESULT" | grep ":" | sed -e "s#raw_cnt.count:##g" -e "s#wifi_header_cnt_##g" -e "s#.count:##g"`

HANDLER_ARRAY=($HANDLER)

PACKET_COUNT=0
MAX_PACKET=0
MAX_PACKET_INDEX=0
INDEX=0

for v in $PACKETS; do
  if [ $PACKET_COUNT -eq 0 ]; then
    PACKET_COUNT=$v
  else
    if [ $v -gt $MAX_PACKET ]; then
      MAX_PACKET=$v
      MAX_PACKET_INDEX=$INDEX
    fi
    INDEX=`expr $INDEX + 1`
  fi
done

echo ${HANDLER_ARRAY[$MAX_PACKET_INDEX]}
