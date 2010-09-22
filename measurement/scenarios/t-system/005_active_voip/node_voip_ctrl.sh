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


NODELIST=`cat $DIR/sender_and_receiver_voip.mes | grep -v "#" | grep "sender_and_receiver_ctrl.click" | awk '{print $1}'`

RUN=1

echo "Nodes: $NODELIST" > $RESULTDIR/nodectrl.log

for i in `seq 3`; do
  echo "sleep $SLEEPTIME sec" >> $RESULTDIR/nodectrl.log

  sleep $SLEEPTIME
done

for i in $NODELIST; do
  echo "START on $i" >> $RESULTDIR/nodectrl.log

  $DIR/../../../../host/bin/clickctrl.sh write $i 7777 ps active true

  if [ $RUN -ge $MINNUM ]; then
   echo "sleep $SLEEPTIME sec" >> $RESULTDIR/nodectrl.log
    sleep $SLEEPTIME

    if [ $RUN -gt $MAXNUM ]; then
      break;
    fi
  fi

  RUN=`expr $RUN + 1`

done

for i in `seq 2`; do
  echo "sleep $SLEEPTIME sec" >> $RESULTDIR/nodectrl.log

  sleep $SLEEPTIME
done

echo "stop all" >> $RESULTDIR/nodectrl.log

for i in $NODELIST; do
  echo "Stop $i" >> $RESULTDIR/nodectrl.log
  $DIR/../../../../host/bin/clickctrl.sh write $i 7777 ps active false
done

exit 0
