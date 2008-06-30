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

SENDERNUM=0

if [ "x$1" = "x" ]; then
    echo "use $0 DATADIR"
    exit 0
fi

DATADIR=$1

if [ "x$RESULTDIR" = "x" ]; then                                                                                                                                                                                 
    RESULTDIR=$DATADIR\_evaluation                                                                                                                                                                               
fi  

for i in `ls $DATADIR`; do

    DUMPS=`(cd $DATADIR/$i/; ls *.dump 2> /dev/null )`

    for dump in $DUMPS; do
	NODE=`echo $dump | sed "s#\.# #g" | awk '{print $1}'`
	DEVICE=`echo $dump | sed "s#\.# #g" | awk '{print $2}'`
    
	while read line; do
	    REGLINE=`echo $line | grep -v "#" | wc -l | awk '{print $1}'`
		
	    if [ $REGLINE -eq 1 ]; then
		SIZE=`echo $line | awk '{print $1}'`
		BITRATE=`echo $line | awk '{print $2}'`
		INTERVAL=`echo $line | awk '{print $3}'`
		
		MINSIZE=`expr $SIZE - 1`
		#BItrate must be doubled since click extra header uses the double (better representation for half rates like 5.5Mbit
		DOUBLEBITRATE=`expr $BITRATE \* 2`

		if [ ! -e $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error ]; then
		    cat $DIR/crcerror.click | sed -e "s#NODE#$NODE#g" -e "s#DEVICE#$DEVICE#g" -e "s#BITRATE#$DOUBLEBITRATE#g" -e "s#MINLEN#$MINSIZE#g" -e "s#MAXLEN#$SIZE#g" > $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.click
		    (cd $DATADIR/$i ; click-align $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.click 2> /dev/null | click 2>&1 | grep -v "^$" | sed -e "s#click.*router##g" > $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error )
		fi
		cat $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error | egrep -v "^[[:space:]]*$" >> $RESULTDIR/all.$SIZE.$BITRATE.crc.error
	    fi

	done < $DATADIR/$SENDERNUM/sender.packets
	
    done

done

exit 0
