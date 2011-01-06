#!/bin/sh

NODES=`cat $1 | grep -v "#" | grep "receiver_mirror.click" | awk '{print $1}' | uniq`
SENDER=`cat $1 | grep -v "#" | grep "sender_mac_rr.click" | awk '{print $1}' | head -n 1`

TIME=$2

if [ "x$DEBUG" = "x" ]; then
  DEBUG=0
fi

for n1 in $NODES $SENDER; do
  echo "$TIME $n1 ath0 write ath_op read_config true"
done

if [ $DEBUG -ne 0 ]; then
  TIME=`expr $TIME + 1`
  for n1 in $NODES $SENDER; do
    echo "$TIME $n1 ath0 read ath_op config"
  done
fi

TIME=`expr $TIME + 1`


sender_suppressor::

for n1 in $NODES; do
  echo "$TIME $n1 ath0 write ath_op set_macclone true"
  echo "$TIME $n1 ath0 write ath_op mac $SENDER:eth"
  echo "$TIME $n1 ath0 write ath_op set_macclone false"
done
