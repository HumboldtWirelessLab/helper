#!/bin/bash

. ./config

STARTDIR=$PWD

rm $WORKERDIR/$1.$2.log

echo $BASHPID > $WORKERDIR/$1.$2.pid

if [ "x$WORKERNICE" != "x" ]; then
  renice -n $WORKERNICE -p $BASHPID
fi

while [ ! -f $PWD/end ]; do

  if [ -f $WORKERDIR/$1.$2.job ]; then
    sleep 1;
    sh $WORKERDIR/$1.$2.job >> $WORKERDIR/$1.$2.log
    cd $STARTDIR
    mv $WORKERDIR/$1.$2.job $WORKERDIR/$1.$2.job.$RANDOM
  else
   sleep 1;
  fi

done

rm $WORKERDIR/$1.$2.pid

exit 0

