#!/bin/sh
SIZE=1043

if [ "x$1" = "x" ]; then
    D=./
else
    D=$1/
fi

echo -n "Receiver 1 (sk110): "
cat $D/receiver_1.log | grep $SIZE | grep "00000080 87000000" | wc  -l
#echo -n "Receiver 2 (sk111): "
#cat ./receiver_2.log | grep $SIZE | wc  -l
#echo -n "Receiver 3 (sk112): "
#cat ./receiver_3.log | grep $SIZE | wc  -l

exit 0
