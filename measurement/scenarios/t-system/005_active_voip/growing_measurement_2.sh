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
STEP=$3
SLEEPTIME=$4

if [ "x$STEP" = "x" ]; then
  STEP=1
fi

rm -f sender_and_receiver_voip.mes sender_and_receiver_voip.dis growing_voip.cfg

if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
  echo "Use $0 min_no_of_clients max_no_of_clients"
fi

SUMRUNTIME=`expr $MAXNUM - $MINNUM + 3`
SUMRUNTIME=`expr $SUMRUNTIME \* $SLEEPTIME`

CONFIGLINES=`expr $MAXNUM`
#CONFIGLINES=`expr $MAXNUM + 3`

cat sender_and_receiver.dis | sed "s#sender_and_receiver.mes#sender_and_receiver_voip.mes#g" | grep -v CONTROLSOCKET | grep -v LOCALPROCESS | grep -v "TIME=" > sender_and_receiver_voip.dis
#cat sender_and_receiver.mes | grep -v "#" | sed "s#sender_and_receiver.click#sender_and_receiver_ctrl.click#g" | head -n $CONFIGLINES > sender_and_receiver_voip.mes

NODES=`cat all_nodes | grep -v "#" | head -n $CONFIGLINES`

rm -f sender_and_receiver_voip.mes

for n in $NODES; do
  echo "$n ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel - sender_and_receiver_ctrl.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> sender_and_receiver_voip.mes
done

echo "tchi2 ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel - receiver.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> sender_and_receiver_voip.mes
echo "pc113 ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel.nc - receiver.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> sender_and_receiver_voip.mes

echo "CONTROLSOCKET=yes" >> sender_and_receiver_voip.dis
echo "LOCALPROCESS=CONFIGDIR/growing_voip.sh" >> sender_and_receiver_voip.dis
echo "TIME=$SUMRUNTIME" >> sender_and_receiver_voip.dis

echo "MINNUM=$1" > $DIR/growing_voip.cfg
echo "MAXNUM=$2" >> $DIR/growing_voip.cfg
echo "STEP=$3" >> $DIR/growing_voip.cfg
echo "SLEEPTIME=$SLEEPTIME" >> $DIR/growing_voip.cfg

#VOIPDIR=`ssh 192.168.4.117 "if [ -e /localhome/testbed/voip ]; then echo '1'; else echo '0'; fi"`
#if [ "x$VOIPDIR" = "x1" ]; then
#  ssh 192.168.4.117 "mv /localhome/testbed/voip /localhome/testbed/voip_$RANDOM"
#fi

#ssh 192.168.4.117 "mkdir /localhome/testbed/voip; chmod 777 /localhome/testbed/voip"

RUNMODE=REBOOT DEV=1 ../../../bin/run_measurement.sh sender_and_receiver_voip.dis 1

#scp 192.168.4.117:/localhome/testbed/voip/*.dump $DIR/1/
#ssh 192.168.4.117 "rm -rf /localhome/testbed/voip"

rm -f sender_and_receiver_voip.mes sender_and_receiver_voip.dis $DIR/growing_voip.cfg

exit 0
