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

DATADIR=`echo $1 | sed -e "s/[\/]*$//g"`

EVALUATIONNUMBER=1

if [ "x$RESULTDIR" = "x" ]; then
    RESULTDIR=$DATADIR\_evaluation
fi

mkdir -p $RESULTDIR

echo -n "EVALUATIONSNUMBER;POINT;NODE;DEVICE;CHANNEL;LONG;LAT;HOG;SENDERNODE;SENDERDEVICE;SENDERLONG;SENDERLAT;SENDERHOG;DISTANCE;DURATION;" > $RESULTDIR/result.csv
echo -n "PACKETS_ALL_ALL;PACKETS_ALL_OK;PACKETS_ALL_CRC;PACKETS_ALL_PHY;" >> $RESULTDIR/result.csv
echo -n "PACKETS_OWN_SIZE;PACKETS_OWN_BITRATE;PACKETS_OWN_INTERVAL;PACKETS_OWN_ALL;PACKETS_OWN_OK;PACKETS_OWN_CRC;PACKETS_OWN_PHY;" >> $RESULTDIR/result.csv
echo -n "MEANPER;STDPER;" >> $RESULTDIR/result.csv
echo -n "MEANRSSI;STDRSSI;RSSI_P5;RSSI_P25;RSSI_P50;RSSI_P75;RSSI_P95;" >> $RESULTDIR/result.csv
echo "FORMEANRSSI;FORSTDRSSI;FORRSSI_P5;FORRSSI_P25;FORRSSI_P50;FORRSSI_P75;FORRSSI_P95;LOS;" >> $RESULTDIR/result.csv

rm -f $RESULTDIR/info.csv

MATLAB_AVAILABLE=`ping -c 1 gruenau.informatik.hu-berlin.de 2>&1 | grep trans | awk '{print $4}'`

mkdir -p $RESULTDIR/$SENDERNUM/
cat $DATADIR/$SENDERNUM/sender.info |  egrep -v "#|^[[:space:]]*$" |awk '{print FNR": "$0}' > $RESULTDIR/$SENDERNUM/sender.info.index

for i in `ls $DATADIR`; do
echo -n "$i "    

    AC_EVALUATIONDIR=$RESULTDIR/$i/

    if [ ! -e $AC_EVALUATIONDIR ]; then
	mkdir -p $AC_EVALUATIONDIR
    fi

     if [ -e $DATADIR/$i/info ]; then
	echo -n "$i: " >> $RESULTDIR/info.log.tmp
	cat $DATADIR/$i/info >> $RESULTDIR/info.log.tmp
	echo "" >> $RESULTDIR/info.log.tmp
    fi

    DUMPS=`(cd $DATADIR/$i/; ls *.dump 2> /dev/null )`
    for dump in $DUMPS; do
	NODE=`echo $dump | sed "s#\.# #g" | awk '{print $1}'`
	DEVICE=`echo $dump | sed "s#\.# #g" | awk '{print $2}'`

	if [ "x$NODE$DEVICE" = "x" ]; then
	    echo "Error to detect node and device"
	    exit 0
	fi

	DISFILE=`cat $DATADIR/$i/measurement.info | grep "DISFILE" | awk '{print $2}'`
          MESFILE=`cat $DATADIR/$i/$DISFILE | grep "NODETABLE" | sed -e "s#=# #g" | awk '{print $2}'`

	if [ -e $DATADIR/$i/$MESFILE ]; then
		WIFICONFIG=`cat $DATADIR/$i/$MESFILE | egrep "$NODE[[:space:]]*$DEVICE" | awk '{print $4}' | sed -e "s#/# #g" | awk '{print $NF}'`
		CHANNEL=`cat $DATADIR/$i/$WIFICONFIG | grep "CHANNEL" | sed -e "s#=# #g" | awk '{print $2}'`;
		WIFITYPE=`cat $DATADIR/$i/$WIFICONFIG | grep "WIFITYPE" | sed -e "s#=# #g" | awk '{print $2}'`;
	else
		echo "cannot find out wifitype and channel of the sender"
		exit 0
	fi

	echo "$WIFICONFIG $CHANNEL $WIFITYPE"

#########################################################
#####################     G P S  S T U F F   #######################
#########################################################

	if [ -e $DATADIR/$SENDERNUM/sender.info ]; then
		SENDERNODE=`cat $DATADIR/$SENDERNUM/sender.info | awk '{print $3" "$1" "$2}' | grep "^$CHANNEL " | sort -u | awk '{print $2}'`
		SENDERDEVICE=`cat $DATADIR/$SENDERNUM/sender.info | awk '{print $3" "$1" "$2}' | grep "^$CHANNEL" | sort -u | awk '{print $3}'`
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

	if [ -e $DATADIR/$SENDERNUM/$SENDERNODE\_gps.info ];	then
		GPSDATARAW=`cat $DATADIR/$SENDERNUM/$SENDERNODE\_gps.info | grep GPGGA | tail -n 1`
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

	if [ ! "$LONG" = "0" ] && [ ! "$LAT" = "0" ] && [ ! "$SENDERLONG" = "0" ] && [ ! "$SENDERLAT" = "0" ]; then
		DISTANCE=`(cd ../bin; java GeoParser $LONG $LAT $SENDERLONG $SENDERLAT)`
	else
		DISTANCE="-1"
	fi

	if [ -e $DATADIR/$i/node.info ]; then
		. $DATADIR/$i/node.info
	fi

	echo "$SENDERNODE;$SENDERDEVICE;$SENDERLONG;$SENDERLAT;$SENDERHOG;" >> $RESULTDIR/sender.csv.tmp

##################################################################
################      G E N E R A L   P A C K E T S T U F F   #########################
##################################################################

	if [ ! -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw ] || [ "x$EMODE" = "xall" ]; then
	    cat $DIR/outdoor_evaluation_$WIFITYPE.click | sed -e "s#NODE#$NODE#g" -e "s#DEVICE#$DEVICE#g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.click

    	    CLICKOUT=`(cd $DATADIR/$i; click-align $AC_EVALUATIONDIR/$NODE.$DEVICE.click 2>&1 | grep -v "warning: added" | click 2>&1)`
	    echo "$CLICKOUT" | grep -v "^$" | sed -e "s#click.*router##g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw
	fi
	
	DISFILE=`(cd $DATADIR/$i; ls *.dis.* | awk '{print $1}')`
	DURATION=`cat $DATADIR/$i/$DISFILE | grep "TIME" | sed "s#=# #g" | awk '{print $2}'`

	if [ ! -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all ] || [ "x$EMODE" = "xall" ]; then
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw | grep -v "Packet::pull" | egrep "OKPacket|CRCerror|Phyerror|TXFeedback" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all
	fi

	if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all ]; then
	    PACKETS_ALL_ALL=`wc -l $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | awk '{print $1}'`
	    PACKETS_ALL_OK=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "OKPacket" | wc -l | awk '{print $1}'`
	    PACKETS_ALL_CRC=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "CRCerror" | wc -l | awk '{print $1}'`
	    PACKETS_ALL_PHY=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "Phyerror" | wc -l | awk '{print $1}'`

	    echo "TIMESTAMP;ERROR;OWN;PACKETSIZE;BITRATE;ID;RSSI;" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv
	
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | sed -e "s#:##g" -e "s#|##g" -e "s#Mb# #g" -e "s#+# #g" -e "s#/# #g" -e "s#Type.*EXTRA##g" | awk '{print $2";"$1";"gsub("80870000","muell",$7)";"$3";"$4";"strtonum("0x"$8)";"$5";"}' | sed -e "s#OKPacket#0#g" -e "s#CRCerror#1#g" -e "s#Phyerror#2#g" | sed -e "s#[[:space:]]*[0-9]*,[0-9]*e+[0-9]*[[:space:]]*# 0 #g" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv | grep -v "TIMESTAMP" | sed -e "s#;# #g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab
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
	echo "CHANNEL=$CHANNEL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "POSITION=$LONG,$LAT,$HOG" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "SENDERNODE=$SENDERNODE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "SENDERDEVICE=$SENDERDEVICE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "SENDERPOSITION=$SENDERLONG,$SENDERLAT,$SENDERHOG" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "DISTANCE=$DISTANCE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_ALL=$PACKETS_ALL_ALL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_OK=$PACKETS_ALL_OK" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_CRC=$PACKETS_ALL_CRC" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_PHY=$PACKETS_ALL_PHY" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view

################################################################################
################   P A C K E T S T U F F   F O R   E A C H   B I T R A T E / S I Z E    #########################
################################################################################

#	if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
#		ssh sombrutz@gruenau.informatik.hu-berlin.de "mkdir ~/tmp" > /dev/null 2>&1
#	fi

	SENDERPARAMS=`cat $AC_EVALUATIONDIR/../$SENDERNUM/sender.info.index | awk '{print $4 $1}' | grep "^$CHANNEL" | awk '{print $2}'`

          for num_senderparm in $SENDERPARAMS; do
		line=`cat $AC_EVALUATIONDIR/../$SENDERNUM/sender.info.index | grep "^$num_senderparm " | awk '{print $7" "$8" "$9}'`

		echo "------------- $line --------------"
		SIZE=`echo $line | awk '{print $1}'`
		BITRATE=`echo $line | awk '{print $2}'`
		INTERVAL=`echo $line | awk '{print $3}'`
		
		SIZEWIFI=`expr $SIZE + 32`

		if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab ]; then
                       cat $DIR/packet_stat_call.m | sed -e "s#SIZEWIFI#$SIZEWIFI#g" -e "s#BITRATE#$BITRATE#g" -e "s#INTERVAL#$INTERVAL#g" -e "s#MATLABFILE#$AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab#g" -e "s#NUMBINS#100#g" -e "s#FILENAME#$AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat.matlab#g" > $AC_EVALUATIONDIR/packet_stat_call.m
                       cat $DIR/packet_stat_print_call.m | sed -e "s#FILENAME#$AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat.matlab#g" > $AC_EVALUATIONDIR/packet_stat_print_call.m 

  		   cp $DIR/packet_stat.m $AC_EVALUATIONDIR/
		   cp $DIR/packet_stat_print.m $AC_EVALUATIONDIR/

		   ( cd $AC_EVALUATIONDIR; octave-2.1.73 -q --funcall packet_stat_call )
		   ( cd $AC_EVALUATIONDIR; octave-2.1.73 -q --funcall packet_stat_print_call > $NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab )
		   ( cd $AC_EVALUATIONDIR; rm -f  packet_stat_print_call.m packet_stat_call.m packet_stat.m packet_stat_print.m )

#		    if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
#		      		scp $AC_EVALUATIONDIR/packet_stat_paint.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
#		      		ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"packet_stat_paint_call;exit\"" > /dev/null 2>&1
#		      		rm -f $AC_EVALUATIONDIR/packet_stat_paint.m
#
#                        		scp sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/*.png  $AC_EVALUATIONDIR/ > /dev/null 2>&1
#		    fi

		    PACKETS_OWN_ALL=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "all_rec_packets" | awk '{print $2}'`
		    PACKETS_OWN_OK=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "ok_packets" | awk '{print $2}'`
		    PACKETS_OWN_CRC=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "crc_packets" | awk '{print $2}'`
		    PACKETS_OWN_PHY=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "phy_packets" | awk '{print $2}'`
		    MEANPER=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "^per:" | awk '{print $2}'`
		    STDPER=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "std_bin_per" | awk '{print $2}'`
		    MEANRSSI=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "mean_rssi" | awk '{print $2}'`
		    STDRSSI=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "std_rssi" | awk '{print $2}'`
		    FORMEANRSSI=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "mean_forrssi" | awk '{print $2}'`
		    FORSTDRSSI=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "std_forrssi" | awk '{print $2}'`
                        FORRSSI_P5=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_forrssi_5:" | awk '{print $2}'`
                        FORRSSI_P25=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_forrssi_25:" | awk '{print $2}'`
                        FORRSSI_P50=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_forrssi_50:" | awk '{print $2}'`
                        FORRSSI_P75=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_forrssi_75:" | awk '{print $2}'`
                        FORRSSI_P95=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_forrssi_95:" | awk '{print $2}'`
                        RSSI_P5=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_rssi_5:" | awk '{print $2}'`
                        RSSI_P25=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_rssi_25:" | awk '{print $2}'`
                        RSSI_P50=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_rssi_50:" | awk '{print $2}'`
                        RSSI_P75=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_rssi_75:" | awk '{print $2}'`
                        RSSI_P95=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab | grep "percentile_rssi_95:" | awk '{print $2}'`
		    LOS=0

		    echo "" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		    echo "PACKETS_OWN_SIZE=$SIZE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		    echo "PACKETS_OWN_BITRATE=$BITRATE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		    echo "PACKET_INTERVAL=$INTERVAL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	    echo "PACKETS_OWN_ALL=$PACKETS_OWN_ALL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
		    echo "PACKETS_OWN_OK=$PACKETS_OWN_OK" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	    echo "PACKETS_OWN_CRC=$PACKETS_OWN_CRC" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	    echo "PACKETS_OWN_PHY=$PACKETS_OWN_PHY" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	   	    echo "MEANPER=$MEANPER" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	   	    echo "STDPER=$STDPER" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	    echo "MEANRSSI=$MEANRSSI" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	    echo "STDRSSI=$STDRSSI" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	    echo "FORMEANRSSI=$FORMEANRSSI" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	    	    echo "FORSTDRSSI=$FORSTDRSSI" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view

	    	    echo -n "$EVALUATIONNUMBER;$i;$NODE;$DEVICE;$CHANNEL;$LONG;$LAT;$HOG;$SENDERNODE;$SENDERDEVICE;$SENDERLONG;$SENDERLAT;$SENDERHOG;$DISTANCE;$DURATION;" >> $RESULTDIR/result.csv
	    	    echo -n "$PACKETS_ALL_ALL;$PACKETS_ALL_OK;$PACKETS_ALL_CRC;$PACKETS_ALL_PHY;"  >> $RESULTDIR/result.csv
		    echo -n "$SIZE;$BITRATE;$INTERVAL;$PACKETS_OWN_ALL;$PACKETS_OWN_OK;$PACKETS_OWN_CRC;$PACKETS_OWN_PHY;$MEANPER;$STDPER;" >> $RESULTDIR/result.csv
                        echo -n "$MEANRSSI;$STDRSSI;$RSSI_P5;$RSSI_P25;$RSSI_P50;$RSSI_P75;$RSSI_P95;" >> $RESULTDIR/result.csv
                        echo "$FORMEANRSSI;$FORSTDRSSI;$FORRSSI_P5;$FORRSSI_P25;$FORRSSI_P50;$FORRSSI_P75;$FORRSSI_P95;$LOS;" >> $RESULTDIR/result.csv
	        fi

	        echo "$EVALUATIONNUMBER;\"$DATADIR/$i\";" >> $RESULTDIR/info.csv
	
	        EVALUATIONNUMBER=`expr $EVALUATIONNUMBER + 1`

	done

    done

done

cat $RESULTDIR/sender.csv.tmp | sort -u > $RESULTDIR/sender.csv
rm $RESULTDIR/sender.csv.tmp
cat $RESULTDIR/result.csv | grep -v "NUMBER" | sed -e "s#;# #g" | awk '{print $3"_"$2" "$5" "$6" "$7}' | grep -v "0 0 0" | sort -u > $RESULTDIR/positions.csv
cat $RESULTDIR/sender.csv | sed -e "s#;# #g" | awk '{print $1"_0 "$3" "$4" "$5}' | sort -u >> $RESULTDIR/positions.csv 

cat $RESULTDIR/info.log.tmp | egrep -v "^[[:space:]]*$" > $RESULTDIR/info.log
rm -f $RESULTDIR/info.log.tmp

echo ""

exit 0

