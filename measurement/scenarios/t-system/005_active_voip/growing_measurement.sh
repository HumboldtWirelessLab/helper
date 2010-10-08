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
STARTSLEEPTIME=$5
STAYSLEEPTIME=$6
ENDSLEEPTIME=$7


if [ "x$STEP" = "x" ]; then
  STEP=1
fi

MES_FILE=sender_and_receiver_voip.mes

rm -f $MES_FILE growing_voip.cfg

if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
  echo "Use [FT=yes [CCA=0|1]] $0 min_no_of_clients max_no_of_clients step sleeptime startdelay staydelay enddelay"
  exit 0
fi

SUMRUNTIME=`expr $MAXNUM - $MINNUM + 1`
SUMRUNTIME=`expr $SUMRUNTIME \* $SLEEPTIME`
SUMRUNTIME=`expr $SUMRUNTIME + $STARTSLEEPTIME + $STAYSLEEPTIME + $ENDSLEEPTIME`

CONFIGLINES=`expr $MAXNUM`

cat sender_and_receiver.dis | grep -v "TIME=" > sender_and_receiver_voip.dis

NODES=`cat all_nodes | grep -v "#" | head -n $CONFIGLINES`

rm -f sender_and_receiver_voip.mes

for n in $NODES; do
  echo "$n ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel.nc - sender_and_receiver.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> $MES_FILE
done

echo "tchi2 ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel - receiver_tchi.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> $MES_FILE
echo "foobar103 ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel.nc BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION receiver.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> $MES_FILE

#foreign traffic
if [ "x$FT" = "xyes" ]; then
  if [ "x$CCA" = "x0" ]; then
    echo "jayto102 ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel.nocca BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION foreign_node.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> $MES_FILE
  else
    echo "jayto102 ath0 BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION - monitor.b.channel.nc BASEDIR/nodes/lib/modules/NODEARCH/KERNELVERSION foreign_node.click LOGDIR/NODENAME.NODEDEVICE.log - -" >> $MES_FILE
  fi
fi

echo "TIME=$SUMRUNTIME" >> sender_and_receiver_voip.dis

echo "MINNUM=$1" > $DIR/growing_voip.cfg
echo "MAXNUM=$2" >> $DIR/growing_voip.cfg
echo "STEP=$3" >> $DIR/growing_voip.cfg
echo "SLEEPTIME=$SLEEPTIME" >> $DIR/growing_voip.cfg
echo "STARTSLEEPTIME=$STARTSLEEPTIME" >> $DIR/growing_voip.cfg
echo "STAYSLEEPTIME=$STAYSLEEPTIME" >> $DIR/growing_voip.cfg
echo "ENDSLEEPTIME=$ENDSLEEPTIME" >> $DIR/growing_voip.cfg

RUNMODE=REBOOT DEV=1 ../../../bin/run_measurement.sh sender_and_receiver_voip.dis 1

rm -f sender_and_receiver_voip.mes sender_and_receiver_voip.dis $DIR/growing_voip.cfg

exit 0
