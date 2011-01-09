#!/bin/sh

NODES=`cat $1 | grep -v "#" | grep -v "sniffer" | grep -v "sender" | awk '{print $1}' | uniq`

SENDERNODE=`cat $1 | grep -v "#" | grep "sender" | awk '{print $1}' | uniq`
SNIFFERNODE=`cat $1 | grep -v "#" | grep "sniffer" | awk '{print $1}' | uniq`

if [ "x$2" = "x" ]; then
  TIME=0
else
  TIME=$2
fi

if [ "x$DEBUG" = "x" ]; then
  DEBUG=0
fi

CNODES=`echo $NODES | wc -w`

COMB=1


for n in `seq 1 $CNODES`; do
  COMB=`expr $COMB \* 2`
done

#remove last combination (all zeros), this would results in no node has target mac
COMB=`expr $COMB - 1`

echo "$CNODES $COMB"

STARTMAC="00-0a-0a-0a-0a-0a"

MAC_PREFIX="00-0a-0a-0a-0b-"

############ RESET ALL NODES TO ONE MAC ##################

for n1 in $NODES $SENDER; do
  echo "$TIME $n1 ath0 write ath_op read_config true"
done

if [ $DEBUG -ne 0 ]; then
  TIME=`expr $TIME + 1`
  for n1 in $NODES $SENDER; do
    echo "$TIME $n1 ath0 read ath_op config"
  done
fi


for i in `seq 1 $COMB`; do

  ############# CALC MAC ###################

  MAC_SUFFIX=`printf "%02x\n" $i`
  MAC="$MAC_PREFIX$MAC_SUFFIX"

  ########## set new macs #################

  ## sender ##
  echo "$TIME $SENDERNODE ath0 write ath_op set_macclone true"
  echo "$TIME $SENDERNODE ath0 write ath_op mac $MAC"
  echo "$TIME $SENDERNODE ath0 write ath_op set_macclone false"
  echo "$TIME $SENDERNODE ath0 write ee src $MAC"
  echo "$TIME $SENDERNODE ath0 write ee dst $MAC"

  m=$i
  for n1 in $NODES; do
    d=`expr $m % 2`
    m=`expr $m / 2`

    echo "$TIME $n1 ath0 write ath_op set_macclone true"

    if [ $d -eq 1 ]; then
      echo "$TIME $n1 ath0 write ath_op mac $MAC"
    else
      echo "$TIME $n1 ath0 write ath_op mac $STARTMAC"
    fi

    echo "$TIME $n1 ath0 write ath_op set_macclone false"

  done

  TIME=`expr $TIME + 1`

  ############ start xmit ##################
  echo "$TIME $SENDERNODE ath0 write sender_suppressor active0 true"
  echo "$TIME $SENDERNODE ath0 write queue_suppressor active0 true"
  echo "$TIME $SENDERNODE ath0 write ps active true"

  TIME=`expr $TIME + 10`
  
  ############ stop xmit ##################

  echo "$TIME $SENDERNODE ath0 write sender_suppressor active0 false"
  echo "$TIME $SENDERNODE ath0 write queue_suppressor active0 false"
  echo "$TIME $SENDERNODE ath0 write ps active false"

  TIME=`expr $TIME + 1`

  ############ reset xmit ##################

  echo "$TIME $SENDERNODE ath0 write wlan_out_queue reset true"
  echo "$TIME $SENDERNODE ath0 write ath_op clear_hw_queues wifi0"

  TIME=`expr $TIME + 1`

done

exit 0
