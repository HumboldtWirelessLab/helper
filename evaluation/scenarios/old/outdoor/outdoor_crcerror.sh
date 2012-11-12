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

DATADIR=`echo $1 | sed -e "s/[\/]*$//g"`

if [ "x$RESULTDIR" = "x" ]; then                                                                                                                                                                                 
    RESULTDIR=$DATADIR\_evaluation                                                                                                                                                                               
fi  

MATLAB_AVAILABLE=`ping -c 1 gruenau.informatik.hu-berlin.de 2>&1 | grep trans | awk '{print $4}'`

if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
	ssh sombrutz@gruenau.informatik.hu-berlin.de "mkdir ~/tmp" > /dev/null 2>&1
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
		
		WIFISIZE=`expr $SIZE + 32`
		
		MINSIZE=`expr $SIZE - 1`
		#BItrate must be doubled since click extra header uses the double (better representation for half rates like 5.5Mbit
		DOUBLEBITRATE=`expr $BITRATE \* 2`

		echo -n "$i "
#		echo "$i $NODE.$DEVICE.$SIZE.$BITRATE"
		
		if [ ! -e $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error ]; then
		    cat $DIR/crcerror.click | sed -e "s#NODE#$NODE#g" -e "s#DEVICE#$DEVICE#g" -e "s#BITRATE#$DOUBLEBITRATE#g" -e "s#MINLEN#$MINSIZE#g" -e "s#MAXLEN#$SIZE#g" > $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.click
		    (cd $DATADIR/$i ; click-align $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.click 2> /dev/null | click 2>&1 | sed -e "s#click.*router##g" | egrep -v "^[[:space:]]*$" > $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error )
		fi

		FILESIZE=`wc -l $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error | awk '{print $1}'`
		
		if [ $FILESIZE -gt 1 ]; then
			cat $DIR/crcerror_plot_func.m | sed -e "s#BITFILE#$NODE.$DEVICE.$SIZE.$BITRATE.crc.error#g" -e "s#PACKETFILE#$NODE.$DEVICE.packets.all.all.matlab#g" -e "s#SIZE#$WIFISIZE#g" -e "s#BITRATE#$BITRATE#g" -e "s#INTERVAL#$INTERVAL#g" > $RESULTDIR/$i/crcerror_plot_func.m
			cp $DIR/crcerror_plot.m $RESULTDIR/$i/
		    
			if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
				scp  $RESULTDIR/$i/crcerror_plot_func.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
				scp  $RESULTDIR/$i/crcerror_plot.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
				scp  $RESULTDIR/$i/$NODE.$DEVICE.$SIZE.$BITRATE.crc.error sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
				scp  $RESULTDIR/$i/$NODE.$DEVICE.packets.all.all.matlab sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
				ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"crcerror_plot_func;exit\"" > /dev/null 2>&1
	 			rm -f $RESULTDIR/$i/crcerror_plot_func.m $RESULTDIR/$i/crcerror_plot.m
				scp sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/*.png  $RESULTDIR/$i/ > /dev/null 2>&1
				ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;rm -f png" > /dev/null 2>&1
			else
				(cd $RESULTDIR/$i/; octave -q --funcall crcerror_plot_func; rm -f ./crcerror_plot_func.m; rm -f ./crcerror_plot.m)
			fi
		fi
	    fi

	done < $DATADIR/$SENDERNUM/sender.packets
	
    done

done

if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
	ssh sombrutz@gruenau.informatik.hu-berlin.de "rm -rf ~/tmp" > /dev/null 2>&1
fi

echo ""

exit 0

