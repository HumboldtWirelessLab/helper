#!/bin/sh

EXDIR=0

WANTED_DIR=$1

while [ $EXDIR -eq 0 ]; do

  if [ ! -d $WANTED_DIR ]; then
    sleep 1
#    echo "not there"
  else
#    echo "is there"
    EXDIR=1
  fi 
done

echo "Wait for start"

sleep $2

echo "run"

exit 0