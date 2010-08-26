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

MINNUM=$1
MAXNUM=$2

rm -f sender_and_receiver_voip.mes sender_and_receiver_voip.dis

if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
  echo "Use $0 min_no_of_clients max_no_of_clients"
fi

RUNNUM=1
USECONFIGLINES=`expr $MINNUM + 3`

while [ $MINNUM -le $MAXNUM ]; do
  cat sender_and_receiver.dis | sed "s#sender_and_receiver.mes#sender_and_receiver_voip.mes#g" > sender_and_receiver_voip.dis
  cat sender_and_receiver.mes | grep -v "#" | head -n $USECONFIGLINES > sender_and_receiver_voip.mes

  VOIPDIR=`ssh 192.168.4.117 "if [ -e /localhome/testbed/voip ]; then echo '1'; else echo '0'; fi"`
  if [ "x$VOIPDIR" = "x1" ]; then
    ssh 192.168.4.117 "mv /localhome/testbed/voip /localhome/testbed/voip_$RANDOM"
  fi
  
  ssh 192.168.4.117 "mkdir /localhome/testbed/voip; chmod 777 /localhome/testbed/voip"
    
  RUNMODE=REBOOT DEV=1 ../../../bin/run_measurement.sh sender_and_receiver_voip.dis $RUNNUM

  scp 192.168.4.117:/localhome/testbed/voip/*.dump $DIR/$RUNNUM/
  ssh 192.168.4.117 "rm -rf /localhome/testbed/voip"
  
  RUNNUM=`expr $RUNNUM + 1`
  USECONFIGLINES=`expr $USECONFIGLINES + 5`
  MINNUM=`expr $MINNUM + 5`
  
  rm -f sender_and_receiver_voip.mes sender_and_receiver_voip.dis
done

exit 0
