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

. $DIR/growing_voip.cfg


NODELIST=`cat $DIR/sender_and_receiver_voip.mes | grep -v "#" | grep "sender_and_receiver.click" | awk '{print $1}' | sed "s#sk110##g" | sed "s#sk111##g" | sed "s#sk112##g"`

RUN=1

#echo "Nodes: $NODELIST" > $DIR/nodectrl.log

sleep $SLEEPTIME

for i in $NODELIST; do
# echo "START on $i" >> $DIR/nodectrl.log
  
  $DIR/../../../../host/bin/clickctrl.sh write $i 7777 ps active true
    
  if [ $RUN -ge $MINNUM ]; then
#   echo "sleep $SLEEPTIME sec" >> $DIR/nodectrl.log
    sleep $SLEEPTIME
  
    if [ $RUN -gt $MAXNUM ]; then
      break;
    fi
  fi
  
  RUN=`expr $RUN + 1`

done

#echo "stop all" >> $DIR/nodectrl.log

for i in $NODELIST; do
  #echo "Stop $i" >> $DIR/nodectrl.log
  $DIR/../../../../host/bin/clickctrl.sh write $i 7777 ps active false
done

exit 0
