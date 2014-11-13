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

$DIR/../lib/parasim/para_sim_ctrl.sh status

USE_DISTPARASIM=$?

MAX_THREADS=4

if [ $USE_DISTPARASIM -eq 1 ]; then
  $DIR/../lib/parasim/para_sim_ctrl.sh cpus
  MAX_THREADS=$?
else
  if [ -e /proc/cpuinfo ]; then
    MAX_THREADS=`cat /proc/cpuinfo | grep processor | wc -l`
  fi
fi

echo "Use dist_para_sim: $USE_DISTPARASIM max. threads: $MAX_THREADS"

NUM=0

WORKINGDIR=$PWD

if [ -f $WORKINGDIR/sim_finish ]; then
  echo "Continue para-sim"
  CONT=1
else
  CONT=0
  echo -n "" > $WORKINGDIR/sim_finish
fi

echo -n "" > $WORKINGDIR/sim_run

COUNT_SIMS=`find -name *.des.sim | wc -l`
FINISHEDSIMS=0

rm -rf $WORKINGDIR/sim_finish_dir
mkdir $WORKINGDIR/sim_finish_dir

SIM_RUN=0
SIM_FIN=0

for i in `find -name *.des.sim`; do

  SIMDIR=`dirname $i`

  #echo $SIMDIR
  if [ $USE_DISTPARASIM -eq 1 ]; then
    JOBCOMMAND="cd $WORKINGDIR/$SIMDIR/;run_again.sh > run_again.log 2>&1; sh ./eval_again.sh > eval_again.log 2>&1; touch $WORKINGDIR/sim_finish_dir/$NUM" $DIR/../lib/parasim/para_sim_ctrl.sh commit
  else
    if [ $CONT -eq 0 ]; then
      (cd $SIMDIR/;run_again.sh > run_again.log 2>&1; sh ./eval_again.sh > eval_again.log 2>&1; cd $WORKINGDIR; touch $WORKINGDIR/sim_finish_dir/$NUM ) &
    else
      DONE=`grep "^$NUM\$" $WORKINGDIR/sim_finish | wc -l`
      if [ $DONE -eq 0 ]; then
        (cd $SIMDIR/;run_again.sh > run_again.log 2>&1; sh ./eval_again.sh > eval_again.log 2>&1; cd $WORKINGDIR; touch $WORKINGDIR/sim_finish_dir/$NUM ) &
      else
        touch $WORKINGDIR/sim_finish_dir/$NUM
      fi
    fi
  fi

  let SIM_RUN=SIM_RUN+1
  echo "$NUM" >> $WORKINGDIR/sim_run

  let NUM=NUM+1

  for fs in `(cd $WORKINGDIR/sim_finish_dir; ls)`; do
    echo $fs >> $WORKINGDIR/sim_finish
    rm $WORKINGDIR/sim_finish_dir/$fs
  done

  SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`

  let SIM_DIFF=SIM_RUN-SIM_FIN

  while [ $SIM_DIFF -gt $MAX_THREADS ]; do
    sleep 1
    echo -n -e "Finished $SIM_FIN of $COUNT_SIMS sims         \033[1G"
    for fs in `(cd $WORKINGDIR/sim_finish_dir; ls)`; do
      echo $fs >> $WORKINGDIR/sim_finish
      rm $WORKINGDIR/sim_finish_dir/$fs
    done
    SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`
    let SIM_DIFF=SIM_RUN-SIM_FIN
  done

done

while [ $SIM_DIFF -ne 0 ]; do
    sleep 1
    echo -n -e "Finished $SIM_FIN of $COUNT_SIMS sims         \033[1G"
    for fs in `(cd $WORKINGDIR/sim_finish_dir; ls)`; do
      echo $fs >> $WORKINGDIR/sim_finish
      rm $WORKINGDIR/sim_finish_dir/$fs
    done
    SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`
    let SIM_DIFF=SIM_RUN-SIM_FIN
done

rm -f $WORKINGDIR/sim_finish $WORKINGDIR/sim_run
rm -rf sim_finish_dir
