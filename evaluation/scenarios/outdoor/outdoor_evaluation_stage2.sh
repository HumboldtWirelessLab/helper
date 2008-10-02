#!/bin/sh

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


if [ "x$1" = "x" ]; then
    echo "use $0 DATADIR"
    exit 0
fi

cat $1/result.csv | grep -v "NUMBER" | awk -F\; '{print $5" "$14" "$43" "$20" "$21" "$17" "$24"  "$44" "$45" "$27" "$29" "$36}' > $1/result.mat

echo "function packet_stat_call()" > $1/outdoor_result_evaluation_call.m
echo "outdoor_result_evaluation('result.mat');"   >> $1/outdoor_result_evaluation_call.m
echo "exit;" >> $1/outdoor_result_evaluation_call.m
echo "end" >> $1/outdoor_result_evaluation_call.m

exit 0

