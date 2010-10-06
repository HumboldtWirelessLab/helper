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


NODELIST=`cat $DIR/sender_and_receiver_voip.mes | grep -v "#" | grep "sender_and_receiver.click" | awk '{print $1}'`

RUN=1

echo "Nodes: $NODELIST" > $RESULTDIR/nodectrl.log

echo "Wait $STARTSLEEPTIME sec to start." >> $RESULTDIR/nodectrl.log
sleep $STARTSLEEPTIME

echo "" > $RESULTDIR/startup_order.dat

for i in $NODELIST; do
  echo "Start voip on node $i." >> $RESULTDIR/nodectrl.log

  $DIR/../../../../host/bin/clickctrl.sh write $i 7777 ps active true
  echo $i >> $RESULTDIR/startup_order.dat

  if [ $RUN -ge $MINNUM ]; then
    echo "Wait $SLEEPTIME sec to start the next node." >> $RESULTDIR/nodectrl.log
    sleep $SLEEPTIME

    if [ $RUN -gt $MAXNUM ]; then
      break;
    fi
  fi

  RUN=`expr $RUN + 1`

done

echo "Stay $STAYSLEEPTIME sec with all nodes." >> $RESULTDIR/nodectrl.log
sleep $STAYSLEEPTIME

echo "Stop all nodes." >> $RESULTDIR/nodectrl.log

for i in $NODELIST; do
  echo "Stop $i." >> $RESULTDIR/nodectrl.log
  $DIR/../../../../host/bin/clickctrl.sh write $i 7777 ps active false
done

echo "Wait $ENDSLEEPTIME sec to let the queue be empty." >> $RESULTDIR/nodectrl.log
sleep $ENDSLEEPTIME

echo "Finished."

exit 0
