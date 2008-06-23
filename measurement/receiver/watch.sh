#!/bin/sh
SIZEBIG=1043
SIZESMALL=53

if [ "x$1" = "x" ]; then
    D=./
else
    D=$1/
fi

echo  "Receiver 1 (sk110): "
echo -n "$SIZEBIG 1Mb: "
cat $D/receiver_1.log | grep $SIZEBIG | grep "1Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZEBIG 6Mb: "
cat $D/receiver_1.log | grep $SIZEBIG | grep "6Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZESMALL 1Mb: "
cat $D/receiver_1.log | grep $SIZESMALL | grep "1Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZESMALL 6Mb: "
cat $D/receiver_1.log | grep $SIZESMALL | grep "6Mb" | grep "00000080 87000000" | wc  -l
echo  "Receiver 2 (sk111): "
echo -n "$SIZEBIG 1Mb: "
cat $D/receiver_2.log | grep $SIZEBIG | grep "1Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZEBIG 6Mb: "
cat $D/receiver_2.log | grep $SIZEBIG | grep "6Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZESMALL 1Mb: "
cat $D/receiver_2.log | grep $SIZESMALL | grep "1Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZESMALL 6Mb: "
cat $D/receiver_2.log | grep $SIZESMALL | grep "6Mb" | grep "00000080 87000000" | wc  -l
echo  "Receiver 3 (sk112): "
echo -n "$SIZEBIG 1Mb: "
cat $D/receiver_3.log | grep $SIZEBIG | grep "1Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZEBIG 6Mb: "
cat $D/receiver_3.log | grep $SIZEBIG | grep "6Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZESMALL 1Mb: "
cat $D/receiver_3.log | grep $SIZESMALL | grep "1Mb" | grep "00000080 87000000" | wc  -l
echo -n "$SIZESMALL 6Mb: "
cat $D/receiver_3.log | grep $SIZESMALL | grep "6Mb" | grep "00000080 87000000" | wc  -l

exit 0
