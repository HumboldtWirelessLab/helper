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

DATADIR=`echo $1 | sed -e "s/[\/]*$//g"`

if [ "x$RESULTDIR" = "x" ]; then
    RESULTDIR=$DATADIR\_evaluation
fi

for i in `ls $DATADIR`; do

    echo "POINT $i "    

    AC_EVALUATIONDIR=$RESULTDIR/$i/

    if [ ! -e $AC_EVALUATIONDIR ]; then
         mkdir -p $AC_EVALUATIONDIR
    fi

    DUMPS=`(cd $DATADIR/$i/; ls *.dump 2> /dev/null )`
    for receiver in $DUMPS; do

	NODE=`echo $receiver | sed "s#\.# #g" | awk '{print $1}'`
	DEVICE=`echo $receiver | sed "s#\.# #g" | awk '{print $2}'`

	echo "Receiver: $NODE $DEVICE"

	if [ "x$NODE$DEVICE" = "x" ]; then
	    echo "Error to detect node and device"
	    exit 0
	fi

	if [ ! -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw ] || [ "x$EMODE" = "xall" ]; then
	    cat $DIR/outdoor_evaluation_805.click | sed -e "s#NODE#$NODE#g" -e "s#DEVICE#$DEVICE#g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.click

    	    CLICKOUT=`(cd $DATADIR/$i; click-align $AC_EVALUATIONDIR/$NODE.$DEVICE.click | grep -v "warning: added" | click 2>&1)`
	    echo "$CLICKOUT" | grep -v "^$" | sed -e "s#click.*router##g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw
	fi

	if [ ! -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all ] || [ "x$EMODE" = "xall" ]; then
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw | grep -v "Packet::pull" | egrep "OKPacket|CRCerror|Phyerror|TXFeedback" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all
	fi

			
	cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | sed -e "s#:##g" -e "s#|##g" -e "s#Mb# #g" -e "s#+# #g" -e "s#/# #g" -e "s#Type.*EXTRA##g" | awk '{print $2";"$1";"gsub("80870000","muell",$7)";"$3";"$4";"strtonum("0x"$8)";"$5";"}' | sed -e "s#OKPacket#0#g" -e "s#CRCerror#1#g" -e "s#Phyerror#2#g" | sed -e "s#[[:space:]]*[0-9]*,[0-9]*e+[0-9]*[[:space:]]*# 0 #g" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv
	cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv | grep -v "TIMESTAMP" | sed -e "s#;# #g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab
    done
done

exit 0
