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

MAX_THREADS=4

if [ -e /proc/cpuinfo ]; then
  MAX_THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
fi

NUM=0

WORKINGDIR=$PWD

echo -n "" > $WORKINGDIR/sim_finish
echo -n "" > $WORKINGDIR/sim_run

COUNT_SIMS=`find -name run_again.sh | wc -l`
FINISHEDSIMS=0

for i in `find -name run_again.sh`; do

  SIMDIR=`dirname $i`

  (cd  $SIMDIR/;sh ./run_again.sh > run_again.log 2>&1; sh ./eval_again.sh > eval_again.log 2>&1; cd $WORKINGDIR; echo $NUM >> $WORKINGDIR/sim_finish ) &
  echo "$NUM" >> $WORKINGDIR/sim_run

  let NUM=NUM+1

  SIM_RUN=`cat $WORKINGDIR/sim_run | wc -l`
  SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`

  let SIM_DIFF=SIM_RUN-SIM_FIN

  while [ $SIM_DIFF -gt $MAX_THREADS ]; do
    sleep 5
    echo -n -e "Finished $SIM_FIN of $COUNT_SIMS sims         \033[1G"
    SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`
    let SIM_DIFF=SIM_RUN-SIM_FIN
  done

done

while [ $SIM_DIFF -ne 0 ]; do
    sleep 5
    echo -n -e "Finished $SIM_FIN of $COUNT_SIMS sims         \033[1G"
    SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`
    let SIM_DIFF=SIM_RUN-SIM_FIN
done

rm -f $WORKINGDIR/sim_finish $WORKINGDIR/sim_run
