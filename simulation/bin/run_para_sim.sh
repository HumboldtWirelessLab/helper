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

. $DIR/../../evaluation/bin/functions.sh

$DIR/../lib/parasim/para_sim_ctrl.sh status

USE_DISTPARASIM=$?

MAX_THREADS=4

if [ $USE_DISTPARASIM -eq 1 ]; then
  $DIR/../lib/parasim/para_sim_ctrl.sh cpus
  MAX_THREADS=$?
else
  MAX_THREADS=`get_cpu_count`
fi

let MIN_THREADS=MAX_THREADS/2

echo "Use dist_para_sim: $USE_DISTPARASIM max. threads: $MAX_THREADS"

NUM=0

WORKINGDIR=$PWD

if [ -f $WORKINGDIR/sim_finish ]; then
  echo "Continue para-sim"
  CONT=1
else
  CONT=0
  echo -n "" > $WORKINGDIR/sim_finish
  echo -n "" > $WORKINGDIR/sim_finish_err
fi

echo -n "" > $WORKINGDIR/sim_run

COUNT_SIMS=`find -name *.des.sim | wc -l`
FINISHEDSIMS=0

rm -rf $WORKINGDIR/sim_finish_dir
mkdir $WORKINGDIR/sim_finish_dir

rm -rf $WORKINGDIR/sim_finish_err_dir
mkdir $WORKINGDIR/sim_finish_err_dir

SIM_RUN=0
SIM_FIN=0
SIM_ERR=0

for i in `find -name *.des.sim`; do

  SIMDIR=`dirname $i`

  #echo $SIMDIR
  if [ $USE_DISTPARASIM -eq 1 ]; then
    JOBCOMMAND="cd $WORKINGDIR/$SIMDIR/; run_again.sh > run_again.log 2>&1; if [ \$? -eq 0 ]; then eval_again.sh > eval_again.log 2>&1; else echo \"$SIMDIR\" > $WORKINGDIR/sim_finish_err_dir/$NUM; fi; touch $WORKINGDIR/sim_finish_dir/$NUM" $DIR/../lib/parasim/para_sim_ctrl.sh commit
  else
    if [ $CONT -eq 0 ]; then
      if [ -e $SIMDIR/time.stats ]; then
        T=`cat $SIMDIR/time.stats | wc -c`
        if [ $T -eq 0 ]; then
          rm $SIMDIR/time.stats
        fi
      fi
      if [ ! -e $SIMDIR/time.stats ]; then
        (cd $SIMDIR/; run_again.sh > run_again.log 2>&1; if [ $? -eq 0 ]; then eval_again.sh > eval_again.log 2>&1; else echo "$SIMDIR" > $WORKINGDIR/sim_finish_err_dir/$NUM; fi; cd $WORKINGDIR; touch $WORKINGDIR/sim_finish_dir/$NUM ) &
      else
        (touch $WORKINGDIR/sim_finish_dir/$NUM ) &
      fi
    else
      DONE=`grep "^$NUM\$" $WORKINGDIR/sim_finish | wc -l`
      if [ $DONE -eq 0 ]; then
        (cd $SIMDIR/; run_again.sh > run_again.log 2>&1; if [ $? -eq 0 ]; then eval_again.sh > eval_again.log 2>&1; else echo "$SIMDIR" > $WORKINGDIR/sim_finish_err_dir/$NUM; fi; cd $WORKINGDIR; touch $WORKINGDIR/sim_finish_dir/$NUM ) &
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
    if [ -f $WORKINGDIR/sim_finish_err_dir/$fs ]; then
      cat $WORKINGDIR/sim_finish_err_dir/$fs >> $WORKINGDIR/sim_finish_err
      rm $WORKINGDIR/sim_finish_err_dir/$fs
    fi
  done

  SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`
  SIM_ERR=`cat $WORKINGDIR/sim_finish_err | wc -l`

  #waiting loop
  let SIM_DIFF=SIM_RUN-SIM_FIN
  LOADAVG=`cat /proc/loadavg | awk -F. '{print $1}'`


  while  [ $SIM_DIFF -gt $MAX_THREADS ] || ( [ $LOADAVG -gt $MAX_THREADS ] && [ $SIM_DIFF -gt $MIN_THREADS ] ); do
    sleep 1
    echo -n -e "Finished $SIM_FIN ($SIM_ERR) of $COUNT_SIMS sims ($SIM_RUN/$SIM_DIFF/$LOADAVG)        \033[1G"
    for fs in `(cd $WORKINGDIR/sim_finish_dir; ls)`; do
      echo $fs >> $WORKINGDIR/sim_finish
      rm $WORKINGDIR/sim_finish_dir/$fs
      if [ -f $WORKINGDIR/sim_finish_err_dir/$fs ]; then
        cat $WORKINGDIR/sim_finish_err_dir/$fs >> $WORKINGDIR/sim_finish_err
        rm $WORKINGDIR/sim_finish_err_dir/$fs
      fi
    done
    SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`
    SIM_ERR=`cat $WORKINGDIR/sim_finish_err | wc -l`

    let SIM_DIFF=SIM_RUN-SIM_FIN
    LOADAVG=`cat /proc/loadavg | awk -F. '{print $1}'`

  done

done

if [ $SIM_RUN -eq 0 ]; then
  echo "No Simulation"
  rm -f $WORKINGDIR/sim_finish $WORKINGDIR/sim_run
  rm -rf $WORKINGDIR/sim_finish_dir $WORKINGDIR/sim_finish_err_dir $WORKINGDIR/sim_finish_err

  exit 0
fi

while [ $SIM_DIFF -ne 0 ]; do
    sleep 1
    echo -n -e "Finished $SIM_FIN ($SIM_ERR) of $COUNT_SIMS sims ($SIM_DIFF/$LOADAVG)         \033[1G"
    for fs in `(cd $WORKINGDIR/sim_finish_dir; ls)`; do
      echo $fs >> $WORKINGDIR/sim_finish
      rm $WORKINGDIR/sim_finish_dir/$fs
      if [ -f $WORKINGDIR/sim_finish_err_dir/$fs ]; then
        cat $WORKINGDIR/sim_finish_err_dir/$fs >> $WORKINGDIR/sim_finish_err
        rm $WORKINGDIR/sim_finish_err_dir/$fs
      fi
    done
    SIM_FIN=`cat $WORKINGDIR/sim_finish | wc -l`
    SIM_ERR=`cat $WORKINGDIR/sim_finish_err | wc -l`

    let SIM_DIFF=SIM_RUN-SIM_FIN
    LOADAVG=`cat /proc/loadavg | awk -F. '{print $1}'`
done

echo "Finished $SIM_FIN of $COUNT_SIMS sims. $SIM_ERR Simulation ends with an error."

if [ $SIM_ERR -ne 0 ]; then
  echo "Check out sim_finish_err for all faulty simulations"
else
  rm -f $WORKINGDIR/sim_finish_err
fi

rm -f $WORKINGDIR/sim_finish $WORKINGDIR/sim_run
rm -rf $WORKINGDIR/sim_finish_dir $WORKINGDIR/sim_finish_err_dir
