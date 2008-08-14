#!/bin/sh

V=1
NODE=110
DISTANCE=55

while [ $V -le 10 ]; do

  RUNX=1
  RUNY=1

  while [ $RUNY -lt $V ]; do
    X=`expr $V \* $DISTANCE`
    Y=`expr $RUNY \* $DISTANCE`

    echo "sk$NODE $X $Y 0"
    RUNY=`expr $RUNY + 1`
    NODE=`expr $NODE + 1`
  done

  while [ $RUNX -le $V ]; do
    Y=`expr $V \* $DISTANCE`
    X=`expr $RUNX \* $DISTANCE`
    echo "sk$NODE $X $Y 0"
    RUNX=`expr $RUNX + 1`
    NODE=`expr $NODE + 1`
  done

  V=`expr $V + 1`

done

exit 0;
