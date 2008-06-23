#!/bin/sh

POSTIONFILE=$1

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

greater() {
GREATER=`(echo "$1"; echo "$2") | sort -u | tail -n 1`
if [ "$1" = "$2" ]; then
	echo "0"
else
	if [ "$GREATER" = "$1" ]; then
		echo "1"
	else
		echo "0"
	fi
fi
}

rm -f $POSTIONFILE.pos.tmp

read line < $POSTIONFILE

LOWX=0
LOWY=0
LOWZ=0

NODE=`echo $line | awk '{print $1}'`
LONG=`echo $line | awk '{print $2}'`
LAT=`echo $line | awk '{print $3}'`
while read inline; do
	NODE=`echo $inline | awk '{print $1}'`
	INLONG=`echo $inline | awk '{print $2}'`
	INLAT=`echo $inline | awk '{print $3}'`
  	YDISTANCE=`(cd $DIR; java GeoParser $LONG $LAT $LONG $INLAT) | sed -e "s#\..*##g"`
	G=`greater $LAT $INLAT`
	if [ $G -eq 1 ]; then
		YDISTANCE="-$YDISTANCE"
	fi
       	XDISTANCE=`(cd $DIR; java GeoParser $LONG $LAT $INLONG $LAT) | sed -e "s#\..*##g"`
	G=`greater $LONG $INLONG`
	if [ $G -eq 1 ]; then
		XDISTANCE="-$XDISTANCE"
	fi
	if [ $XDISTANCE -lt $LOWX ]; then
		LOWX=$XDISTANCE
	fi
	if [ $YDISTANCE -lt $LOWY ]; then
		LOWY=$YDISTANCE
	fi

	echo "$NODE $XDISTANCE $YDISTANCE 0" >> $POSTIONFILE.pos.tmp
done < $POSTIONFILE

rm -f $POSTIONFILE.pos

while read inline; do
	echo "$inline $LOWX $LOWY" | awk '{print $1" "$2-$5+50" "$3-$6+50" "$4-$7}' >> $POSTIONFILE.pos
done < $POSTIONFILE.pos.tmp

rm -f $POSTIONFILE.pos.tmp

exit 0

