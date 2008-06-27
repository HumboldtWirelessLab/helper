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

#GPGGA
gpgga_print() {
    LINE=`echo "$1" | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
    TIME=`echo "$LINE" | awk '{print $2}'`
    LATITUDE=`echo "$LINE" | awk '{print $3}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LATITUDE_POST=`echo "$LINE" | awk '{print $4}'`
    LONGITUDE=`echo "$LINE" | awk '{print $5}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LONGITUDE_POST=`echo "$LINE" | awk '{print $6}'`
    QUALITY=`echo "$LINE" | awk '{print $7}'`
    SATELLITES=`echo "$LINE" | awk '{print $8}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    HDOP=`echo "$LINE" | awk '{print $9}'`
    HOG=`echo "$LINE" | awk '{print $10}'`
    HOG_POST=`echo "$LINE" | awk '{print $11}'`
    HGM=`echo "$LINE" | awk '{print $12}'`
    HGM_POST=`echo "$LINE" | awk '{print $13}'`
    EMPTY=`echo "$LINE" | awk '{print $14}'`
    EMPTY2=`echo "$LINE" | awk '{print $15}'`
    CHECKSUM=`echo "$LINE" | awk '{print $16}'`

    echo "Time: $TIME"
    echo "Latitude: $LATITUDE $LATITUDE_POST"
    echo "Longitude: $LONGITUDE $LONGITUDE_POST"
    echo "Qualtity: $QUALITY"
    echo "Satellites: $SATELLITES"
    echo "HDOP: $HDOP"
    echo "HOG: $HOG $HOG_POST"
    echo "HGM: $HGM $HGM_POST"
    echo "Checksum: $CHECKSUM"
}

gps_calc() {
	PR=`echo $1 | sed "s#\.# #g" | awk '{print $1}'`
	PO=`echo $1 | sed "s#\.# #g" | awk '{print $2}'`
	PR1=`echo $PR | cut -b 1,2`
	PR2=`echo $PR | cut -b 3,4`
	POC=`calc $PR2$PO / 6  | sed -e "s#~##g" | awk '{print $1}' | sed "s#\.##g"`
	echo "$PR1.$POC"
}

if [ "x$1" = "x" ]; then
    echo "use $0 DATADIR"
    exit 0
fi

DATADIR=$1
COUNTERTAIL=24

EVALUATIONNUMBER=1

if [ "x$RESULTDIR" = "x" ]; then
    RESULTDIR=$DATADIR\_evaluation
fi

mkdir -p $RESULTDIR

echo -n "EVALUATIONSNUMBER;POINT;NODE;DEVICE;LONG;LAT;HOG;SENDERNODE;SENDERDEVICE;SENDERLONG;SENDERLAT;SENDERHOG;DISTANCE;DURATION;" > $RESULTDIR/result.csv
echo -n "PACKETS_ALL_ALL;PACKETS_ALL_OK;PACKETS_ALL_CRC;PACKETS_ALL_PHY;" >> $RESULTDIR/result.csv
echo -n "PACKETS_OWN_SIZE;PACKETS_OWN_BITRATE;PACKETS_OWN_INTERVAL;PACKETS_OWN_ALL;PACKETS_OWN_OK;PACKETS_OWN_CRC;PACKETS_OWN_PHY;" >> $RESULTDIR/result.csv
echo "PER;MEANRSSI;STDRSSI;" >> $RESULTDIR/result.csv

rm -f $RESULTDIR/info.csv

for i in `ls $DATADIR`; do
echo -n "$i "    

    AC_EVALUATIONDIR=$RESULTDIR/$i/

    if [ ! -e $AC_EVALUATIONDIR ]; then
	mkdir -p $AC_EVALUATIONDIR
    fi
    
    DUMPS=`(cd $DATADIR/$i/; ls *.dump 2> /dev/null )`
    for dump in $DUMPS; do
	NODE=`echo $dump | sed "s#\.# #g" | awk '{print $1}'`
	DEVICE=`echo $dump | sed "s#\.# #g" | awk '{print $2}'`
    
#########################################################
#####################     G P S  S T U F F   #######################
#########################################################

	if [ "x$NODE$DEVICE" = "x" ]; then
	    echo "Error to detect node and device"
	    exit 0
	fi
    
	LAT=0
	LONG=0
	HOG=0
	SENDERLAT=0
	SENDERLONG=0
	SENDERHOG=0

	if [ -e $DATADIR/$i/$NODE\_gps.info ];	then
		GPSDATARAW=`cat $DATADIR/$i/$NODE\_gps.info | grep GPGGA | tail -n 1`
		if [ "x$GPSDATARAW" != "x" ]; then
			GPSDATA=`gpgga_print "$GPSDATARAW"`
			QUAL=`echo "$GPSDATA" | grep "Qualtity" | awk '{print $2}'`
			if [ $QUAL -eq 1 ] || [ $QUAL -eq 2 ]; then
				LAT=`echo "$GPSDATA" | grep Latitude | awk '{print $2}'`
    				LONG=`echo "$GPSDATA" | grep Longitude | awk '{print $2}'`
				LAT=`gps_calc $LAT`
				LONG=`gps_calc $LONG`
				HOG=`echo "$GPSDATA" | grep HOG | awk '{print $2}'`
			fi
		fi
	fi

	if [ -e $DATADIR/$SENDERNUM/sender_gps.info ];	then
		GPSDATARAW=`cat $DATADIR/$SENDERNUM/sender_gps.info | grep GPGGA | tail -n 1`
		if [ "x$GPSDATARAW" != "x" ]; then
			GPSDATA=`gpgga_print "$GPSDATARAW"`
			QUAL=`echo "$GPSDATA" | grep "Qualtity" | awk '{print $2}'`
			if [ $QUAL -eq 1 ] || [ $QUAL -eq 2 ]; then
				SENDERLAT=`echo "$GPSDATA" | grep Latitude | awk '{print $2}'`
    				SENDERLONG=`echo "$GPSDATA" | grep Longitude | awk '{print $2}'`
				SENDERLAT=`gps_calc $SENDERLAT`
				SENDERLONG=`gps_calc $SENDERLONG`
				SENDERHOG=`echo "$GPSDATA" | grep HOG | awk '{print $2}'`
			fi
		fi
	fi

	DISTANCE="-1"

	if [ ! "$LONG" = "0" ] && [ ! "$LAT" = "0" ] && [ ! "$SENDERLONG" = "0" ] && [ ! "$SENDERLAT" = "0" ]; then
		DISTANCE=`(cd ../bin; java GeoParser $LONG $LAT $SENDERLONG $SENDERLAT)`
	fi

	if [ -e $DATADIR/$i/node.info ]; then
		. $DATADIR/$i/node.info
	fi

	if [ -e $DATADIR/0/sender.info ]; then
		SENDERNODE=`cat $DATADIR/0/sender.info | grep "NODE" | sed -e "s#=# #g" | awk '{print $2}'`
		SENDERDEVICE=`cat $DATADIR/0/sender.info | grep "DEVICE" | sed -e "s#=# #g" | awk '{print $2}'`
	fi

	echo "$SENDERNODE;$SENDERDEVICE;$SENDERLONG;$SENDERLAT;$SENDERHOG;" >> $RESULTDIR/sender.csv.tmp

#########################################################
################      P A C K E T S T U F F   #########################
#########################################################

	if [ ! -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw ] || [ "x$EMODE" = "xall" ]; then
	    cat $DIR/outdoor_evaluation.click | sed -e "s#NODE#$NODE#g" -e "s#DEVICE#$DEVICE#g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.click

    	    CLICKOUT=`(cd $DATADIR/$i; click-align $AC_EVALUATIONDIR/$NODE.$DEVICE.click 2>&1 | grep -v "warning: added" | click 2>&1)`
	    echo "$CLICKOUT" | grep -v "^$" | sed -e "s#click.*router##g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw
	fi
	
	DISFILE=`(cd $DATADIR/$i; ls *.dis.* | awk '{print $1}')`
	DURATION=`cat $DATADIR/$i/$DISFILE | grep "TIME" | sed "s#=# #g" | awk '{print $2}'`

	if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw ]; then
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw | grep -v "Packet::pull" | egrep "OKPacket|CRCerror|Phyerror|TXFeedback" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all
	fi

	if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw ]; then
	    RAWCOUNTER=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw | grep -v "Packet::pull" | tail -n $COUNTERTAIL`
	    PACKETSTATS=""
	    for r in $RAWCOUNTER; do
	        PACKETSTATS="$PACKETSTATS $r"
	    done

	    echo "$PACKETSTATS" | awk '{print $2" "$4" "$6" "$8" "$10" "$12" "$14" "$16" "$18" "$20" "$22" "$24}' > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.stats
	    
	fi

	if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all ]; then
	    PACKETS_ALL_ALL=`wc -l $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | awk '{print $1}'`
	    PACKETS_ALL_OK=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "OKPacket" | wc -l | awk '{print $1}'`
	    PACKETS_ALL_CRC=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "CRCerror" | wc -l | awk '{print $1}'`
	    PACKETS_ALL_PHY=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "Phyerror" | wc -l | awk '{print $1}'`

	    rm -f $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab
	    rm -f $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv
	    echo "TIMESTAMP;ERROR;OWN;PACKETSIZE;BITRATE;ID;RSSI;" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv
	
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | sed -e "s#:##g" -e "s#|##g" -e "s#Mb# #g" -e "s#+# #g" -e "s#/# #g" -e "s#Type.*EXTRA##g" | awk '{print $2";"$1";"gsub("80870000","muell",$7)";"$3";"$4";"strtonum("0x"$8)";"$5";"}' | sed -e "s#OKPacket#0#g" -e "s#CRCerror#1#g" -e "s#Phyerror#2#g" | sed -e "s#[[:space:]]*[0-9]*,[0-9]*e+[0-9]*[[:space:]]*# 0 #g" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv | grep -v "TIMESTAMP" | sed -e "s#;# #g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab

	    MATLAB_AVAILABLE=`ping -c 1 gruenau.informatik.hu-berlin.de 2>&1 | grep trans | awk '{print $4}'`

	    if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
		ssh sombrutz@gruenau.informatik.hu-berlin.de "mkdir ~/tmp" > /dev/null 2>&1
		scp $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/ > /dev/null 2>&1
		scp $DIR/rssi_per.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/ > /dev/null 2>&1
	    fi

	else
	    PACKETS_ALL_ALL=0
	    PACKETS_ALL_OK=0
	    PACKETS_ALL_CRC=0
	    PACKETS_ALL_PHY=0
	fi

	echo "NUMBER=$EVALUATIONNUMBER" > $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "POINT=$i" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "NODE=$NODE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "DEVICE=$DEVICE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "POSITION=$LONG,$LAT,$HOG" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "SENDERNODE=$SENDERNODE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "SENDERDEVICE=$SENDERDEVICE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "SENDERPOSITION=$SENDERLONG,$SENDERLAT,$SENDERHOG" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "DISTANCE=$DISTANCE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_ALL=$PACKETS_ALL_ALL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_OK=$PACKETS_ALL_OK" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_CRC=$PACKETS_ALL_CRC" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_PHY=$PACKETS_ALL_PHY" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view

	while read line; do
	    REGLINE=`echo $line | grep -v "#" | wc -l | awk '{print $1}'`
		
	    if [ $REGLINE -eq 1 ]; then
		SIZE=`echo $line | awk '{print $1}'`
		BITRATE=`echo $line | awk '{print $2}'`
		INTERVAL=`echo $line | awk '{print $3}'`
		
		SIZEWIFI=`expr $SIZE + 32`

		if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all ]; then
		    PACKETS_OWN_ALL=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | egrep ":[ ]*$SIZEWIFI \| " | grep "EXTRA: 8087" | grep " $BITRATE\Mb " | wc -l | awk '{print $1}'`
		    PACKETS_OWN_OK=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "OKPacket" | egrep ":[ ]*$SIZEWIFI \| " | grep "EXTRA: 8087" | grep " $BITRATE\Mb " | wc -l | awk '{print $1}'`
		    PACKETS_OWN_CRC=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "CRCerror" | egrep ":[ ]*$SIZEWIFI \| " | grep "EXTRA: 8087" | grep " $BITRATE\Mb " | wc -l | awk '{print $1}'`
		    PACKETS_OWN_PHY=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "Phyerror" | egrep ":[ ]*$SIZEWIFI \| " | grep "EXTRA: 8087" | grep " $BITRATE\Mb " | wc -l | awk '{print $1}'`

		    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab | awk '{print $2" "$3" "$4" "$5" "$7}' | egrep "^0 1 $SIZEWIFI $BITRATE" | awk '{print $5}' > $AC_EVALUATIONDIR/$NODE.$DEVICE.rssi.own.$SIZE.$BITRATE.all
		    cp $AC_EVALUATIONDIR/$NODE.$DEVICE.rssi.own.$SIZE.$BITRATE.all $AC_EVALUATIONDIR/rssi.own.all
		    FILESIZE=`wc -l $AC_EVALUATIONDIR/rssi.own.all | awk '{print $1}'`

		    if [ $FILESIZE -gt 0 ]; then
			(cd $AC_EVALUATIONDIR ; octave $DIR/rssi.m | egrep "me =|st =" ) > $AC_EVALUATIONDIR/$NODE.$DEVICE.rssi.own.$SIZE.$BITRATE.stat
			MEANRSSI=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.rssi.own.$SIZE.$BITRATE.stat | grep "me" | awk '{print $3}'`
			STDRSSI=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.rssi.own.$SIZE.$BITRATE.stat | grep "st" | awk '{print $3}'`
		    else
			MEANRSSI=0
			STDRSSI=0
		    fi

		    rm $AC_EVALUATIONDIR/rssi.own.all
		    DURATIONMS=`expr $DURATION \* 1000`
                        PACKETS_OVERALL=`echo "scale=5; $DURATIONMS/$INTERVAL; quit" | calc | sed -e "s#~##g" | awk '{print $1}'`
		    SUCCESS=`echo "scale=5; $PACKETS_OWN_OK/$PACKETS_OVERALL; quit" | calc | sed -e "s#~##g" | awk '{print $1}'`
		    PER=`echo "scale=5; 1 - $SUCCESS; quit" | calc | sed -e "s#~##g" | awk '{print $1}'`

		else
		    PACKETS_OWN_ALL=0
		    PACKETS_OWN_OK=0
		    PACKETS_OWN_CRC=0
		    PACKETS_OWN_PHY=0
		    MEANRSSI=0
		    STDRSSI=0
		    PER=1.0
		fi
		echo "" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		echo "PACKETS_OWN_SIZE=$SIZE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		echo "PACKETS_OWN_BITRATE=$BITRATE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		echo "PACKET_INTERVAL=$INTERVAL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	echo "PACKETS_OWN_ALL=$PACKETS_OWN_ALL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		echo "PACKETS_OWN_OK=$PACKETS_OWN_OK" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	echo "PACKETS_OWN_CRC=$PACKETS_OWN_CRC" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	echo "PACKETS_OWN_PHY=$PACKETS_OWN_PHY" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	   	echo "PER=$PER" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	echo "MEANRSSI=$MEANRSSI" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	echo "STDRSSI=$STDRSSI" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view

	    	echo -n "$EVALUATIONNUMBER;$i;$NODE;$DEVICE;$LONG;$LAT;$HOG;$SENDERNODE;$SENDERDEVICE;$SENDERLONG;$SENDERLAT;$SENDERHOG;$DISTANCE;$DURATION;" >> $RESULTDIR/result.csv
	    	echo -n "$PACKETS_ALL_ALL;$PACKETS_ALL_OK;$PACKETS_ALL_CRC;$PACKETS_ALL_PHY;"  >> $RESULTDIR/result.csv
		echo "$SIZE;$BITRATE;$INTERVAL;$PACKETS_OWN_ALL;$PACKETS_OWN_OK;$PACKETS_OWN_CRC;$PACKETS_OWN_PHY;$PER;$MEANRSSI;$STDRSSI;" >> $RESULTDIR/result.csv
	    
	    	echo "$EVALUATIONNUMBER;\"$DATADIR/$i\";" >> $RESULTDIR/info.csv
	
	          EVALUATIONNUMBER=`expr $EVALUATIONNUMBER + 1`

	    fi


	done < $DATADIR/$SENDERNUM/sender.packets

	if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
		for rssifile in `(cd $AC_EVALUATIONDIR/; ls $NODE.$DEVICE.rssi.own.*.all)`; do
		      PACKETSIZE=`echo "$rssifile" | sed -e "s#\.# #g" | awk '{print $5}'`
		      BITRATE=`echo "$rssifile" | sed -e "s#\.# #g" | awk '{print $6}'`
		      INTERVAL=`cat $DATADIR/$SENDERNUM/sender.packets | egrep "^$PACKETSIZE[[:space:]]*$BITRATE[[:space:]]" | awk '{print $3}'`
	
                          SIZEWIFI=`expr $PACKETSIZE + 32`

		      cat $DIR/rssi_per_func.m | sed -e "s#FILENAME#$NODE.$DEVICE.packets.all.all.matlab#g" -e "s#BITRATE#$BITRATE#g" -e "s#PACKETSIZE#$SIZEWIFI#g"  -e "s#INTERVAL#$INTERVAL#g" > $AC_EVALUATIONDIR/rssi_per_func.m
		      scp $AC_EVALUATIONDIR/rssi_per_func.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
		      ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"rssi_per_func;exit\"" > /dev/null 2>&1
 		      rm -f $AC_EVALUATIONDIR/rssi_per_func.m
		done
 
                    scp sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/*.png  $AC_EVALUATIONDIR/ > /dev/null 2>&1

	fi

	ssh sombrutz@gruenau.informatik.hu-berlin.de "rm -rf ~/tmp" > /dev/null 2>&1
	
    done

done

cat $RESULTDIR/sender.csv.tmp | sort -u > $RESULTDIR/sender.csv
rm $RESULTDIR/sender.csv.tmp
cat $RESULTDIR/result.csv | grep -v "NUMBER" | sed -e "s#;# #g" | awk '{print $3"_"$2" "$5" "$6" "$7}' | grep -v "0 0 0" | sort -u > $RESULTDIR/positions.csv
cat $RESULTDIR/sender.csv | sed -e "s#;# #g" | awk '{print $1"_0 "$3" "$4" "$5}' | sort -u >> $RESULTDIR/positions.csv 
echo ""

exit 0
