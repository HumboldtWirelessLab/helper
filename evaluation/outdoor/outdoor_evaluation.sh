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

mkdir -p $RESULTDIR
rm -f $RESULTDIR/info.csv

SENDERNUM=0
EVALUATIONNUMBER=1

REMOTEMATLAB_AVAILABLE=`ping -c 1 gruenau.informatik.hu-berlin.de 2>&1 | grep trans | awk '{print $4}'`
LOCALMATLAB=`which matlab`
if [ "x$LOCALMATLAB" = "x" ]; then
	LOCALMATLAB=octave-2.1.73
	MATLAB_OPTION="-q --funcall"
	MATLAB_AVAILABLE=0
else
	MATLAB_AVAILABLE=1
	MATLAB_OPTION="-nodesktop -nojvm -nosplash -r"
fi

echo -n "EVALUATIONSNUMBER;POINT;NODE;DEVICE;CHANNEL;LONG;LAT;HOG;SENDERNODE;SENDERDEVICE;SENDERLONG;SENDERLAT;SENDERHOG;DISTANCE;DURATION;" > $RESULTDIR/result.csv
echo -n "PACKETS_ALL_ALL;PACKETS_ALL_OK;PACKETS_ALL_CRC;PACKETS_ALL_PHY;" >> $RESULTDIR/result.csv
echo -n "PACKETS_OWN_SIZE;PACKETS_OWN_BITRATE;PACKETS_OWN_INTERVAL;PACKETS_OWN_ALL;PACKETS_OWN_OK;PACKETS_OWN_CRC;PACKETS_OWN_PHY;" >> $RESULTDIR/result.csv
echo -n "MEANPER;STDPER;" >> $RESULTDIR/result.csv
echo -n "MEANRSSI;STDRSSI;RSSI_P5;RSSI_P25;RSSI_P50;RSSI_P75;RSSI_P95;" >> $RESULTDIR/result.csv
echo "FORMEANRSSI;FORSTDRSSI;FORRSSI_P5;FORRSSI_P25;FORRSSI_P50;FORRSSI_P75;FORRSSI_P95;LOS;" >> $RESULTDIR/result.csv

for i in `ls $DATADIR`; do

    echo "POINT $i "    

    AC_EVALUATIONDIR=$RESULTDIR/$i/

    if [ ! -e $AC_EVALUATIONDIR ]; then
         mkdir -p $AC_EVALUATIONDIR
    fi

    if [ -e $DATADIR/$i/info ]; then
        echo -n "$i: " >> $RESULTDIR/info.log.tmp
        cat $DATADIR/$i/info >> $RESULTDIR/info.log.tmp
        echo "" >> $RESULTDIR/info.log.tmp
    fi

    if [ -e $DATADIR/$i/measurement.info ]; then
        DISFILE=`cat $DATADIR/$i/measurement.info | grep "DISFILE" | awk '{print $2}'`
        MESFILE=`cat $DATADIR/$i/$DISFILE | grep "NODETABLE" | sed -e "s#=# #g" | awk '{print $2}'`
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

##################################################################
#####################    R E C E I V E R   G P S  S T U F F   #######################
##################################################################

	if [ -e $DATADIR/$i/$NODE\_gps.info ]; then
                  POSITION=`$DIR/../bin/gps_tool.sh getposition $DATADIR/$i/$NODE\_gps.info`
                  LAT=`echo "$POSITION" | awk '{print $1}'`
                  LONG=`echo "$POSITION" | awk '{print $2}'`
                  HOG=`echo "$POSITION" | awk '{print $3}'`
          else
                  LAT=0
                  LONG=0
                  HOG=0
         fi

         if [ -e $DATADIR/$i/$MESFILE ]; then
		WIFICONFIG=`cat $DATADIR/$i/$MESFILE | egrep "$NODE[[:space:]]*$DEVICE" | awk '{print $4}' | sed -e "s#/# #g" | awk '{print $NF}'`
		CHANNEL=`cat $DATADIR/$i/$WIFICONFIG | grep "CHANNEL" | sed -e "s#=# #g" | awk '{print $2}'`;
		WIFITYPE=`cat $DATADIR/$i/$WIFICONFIG | grep "WIFITYPE" | sed -e "s#=# #g" | awk '{print $2}'`;
         else
		echo "cannot find out wifitype and channel of the sender"
		exit 0
         fi

	echo "CHANNEL: $CHANNEL  WIFITYPE: $WIFITYPE"

##################################################################
################      G E N E R A L   P A C K E T S T U F F   #########################
##################################################################

	if [ ! -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw ] || [ "x$EMODE" = "xall" ]; then
	    cat $DIR/outdoor_evaluation_$WIFITYPE.click | sed -e "s#NODE#$NODE#g" -e "s#DEVICE#$DEVICE#g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.click

    	    CLICKOUT=`(cd $DATADIR/$i; click-align $AC_EVALUATIONDIR/$NODE.$DEVICE.click 2>&1 | grep -v "warning: added" | click 2>&1)`
	    echo "$CLICKOUT" | grep -v "^$" | sed -e "s#click.*router##g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw
	fi

	if [ ! -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all ] || [ "x$EMODE" = "xall" ]; then
	    cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.raw | grep -v "Packet::pull" | egrep "OKPacket|CRCerror|Phyerror|TXFeedback" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all
	fi

	DURATION=`cat $DATADIR/$i/$DISFILE | grep "TIME" | sed "s#=# #g" | awk '{print $2}'`

	PACKETS_ALL_ALL=0
	PACKETS_ALL_OK=0
	PACKETS_ALL_CRC=0
	PACKETS_ALL_PHY=0

	if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all ]; then
	          echo "TIMESTAMP;ERROR;OWN;PACKETSIZE;BITRATE;ID;RSSI;" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv

		MATLABFILESIZE=`wc -c $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | awk '{print $1}'`
		if [ $MATLABFILESIZE -gt 0 ]; then
	    		PACKETS_ALL_ALL=`wc -l $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | awk '{print $1}'`
	    		PACKETS_ALL_OK=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "OKPacket" | wc -l | awk '{print $1}'`
	    		PACKETS_ALL_CRC=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "CRCerror" | wc -l | awk '{print $1}'`
	    		PACKETS_ALL_PHY=`cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | grep "Phyerror" | wc -l | awk '{print $1}'`
			
	    		cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all | sed -e "s#:##g" -e "s#|##g" -e "s#Mb# #g" -e "s#+# #g" -e "s#/# #g" -e "s#Type.*EXTRA##g" | awk '{print $2";"$1";"gsub("80870000","muell",$7)";"$3";"$4";"strtonum("0x"$8)";"$5";"}' | sed -e "s#OKPacket#0#g" -e "s#CRCerror#1#g" -e "s#Phyerror#2#g" | sed -e "s#[[:space:]]*[0-9]*,[0-9]*e+[0-9]*[[:space:]]*# 0 #g" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv
	    		cat $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.csv | grep -v "TIMESTAMP" | sed -e "s#;# #g" > $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab
		fi
	else
		MATLABFILESIZE=0
	fi

	echo "NUMBER=$EVALUATIONNUMBER" > $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "POINT=$i" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "NODE=$NODE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "DEVICE=$DEVICE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "CHANNEL=$CHANNEL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "POSITION=$LONG,$LAT,$HOG" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_ALL=$PACKETS_ALL_ALL" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_OK=$PACKETS_ALL_OK" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_CRC=$PACKETS_ALL_CRC" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
	echo "PACKETS_ALL_PHY=$PACKETS_ALL_PHY" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view

	if [ -e $DATADIR/$SENDERNUM/sender.info ]; then
		SENDERNODES=`cat $DATADIR/$SENDERNUM/sender.info | grep -v "#" | awk '{print $3" "$1}' | grep "^$CHANNEL " | sort -u | awk '{print $2}'`
	fi

	for SENDERNODE in $SENDERNODES; do
		
################################################################
#####################    S E N D E R   G P S  S T U F F   #######################
################################################################

	    if [ -e $DATADIR/$SENDERNUM/$SENDERNODE\_gps.info ]; then
                  SENDERPOSITION=`$DIR/../bin/gps_tool.sh getposition $DATADIR/$SENDERNUM/$SENDERNODE\_gps.info`
                  SENDERLAT=`echo "$SENDERPOSITION" | awk '{print $1}'`
                  SENDERLONG=`echo "$SENDERPOSITION" | awk '{print $2}'`
                  SENDERHOG=`echo "$SENDERPOSITION" | awk '{print $3}'`
             else
                  SENDERLAT=0
                  SENDERLONG=0
                  SENDERHOG=0 
             fi

             if [ ! "$LONG" = "0" ] && [ ! "$LAT" = "0" ] && [ ! "$SENDERLONG" = "0" ] && [ ! "$SENDERLAT" = "0" ]; then
                  DISTANCE=`(cd ../bin; java GeoParser $LONG $LAT $SENDERLONG $SENDERLAT)`
             else
                  DISTANCE="-1"
             fi

             SENDERDEVICES=`cat $DATADIR/$SENDERNUM/sender.info | grep -v "#" | awk '{print $3" "$1" "$2}' | grep "^$CHANNEL $SENDERNODE " | sort -u | awk '{print $3}'`

             for SENDERDEVICE in $SENDERDEVICES; do

                 echo "SENDERNODE=$SENDERNODE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
                 echo "SENDERDEVICE=$SENDERDEVICE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
                 echo "SENDERPOSITION=$SENDERLONG,$SENDERLAT,$SENDERHOG" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view
                 echo "DISTANCE=$DISTANCE" >> $AC_EVALUATIONDIR/$NODE.$DEVICE.result.view

                 echo "$SENDERNODE;$SENDERDEVICE;$SENDERLONG;$SENDERLAT;$SENDERHOG;$CHANNEL;" >> $RESULTDIR/sender.csv.tmp

################################################################################
################   P A C K E T S T U F F   F O R   E A C H   B I T R A T E / S I Z E    #########################
################################################################################

	       if [ "x$REMOTEMATLAB_AVAILABLE" = "x1" ] && [ "x$MATLAB_AVAILABLE" != "x1" ]; then
		ssh sombrutz@gruenau.informatik.hu-berlin.de "mkdir ~/tmp" > /dev/null 2>&1
	       fi

                 BITRATES=`cat $DATADIR/$SENDERNUM/sender.info | grep -v "#" | awk '{print $1" "$2" "$7}' | grep "^$SENDERNODE $SENDERDEVICE " | sort -u | awk '{print $3}'`

                 for BITRATE in $BITRATES; do
	            PSIZES=`cat $DATADIR/$SENDERNUM/sender.info | grep -v "#" | awk '{print $1" "$2" "$7" "$6}' | grep "^$SENDERNODE $SENDERDEVICE $BITRATE " | sort -u | awk '{print $4}'`

                      for SIZE in $PSIZES; do
                          INTERVAL=`cat $DATADIR/$SENDERNUM/sender.info | grep -v "#" | awk '{print $1" "$2" "$7" "$6" "$8}' | grep "^$SENDERNODE $SENDERDEVICE $BITRATE $SIZE " | sort -u | awk '{print $5}'`
		
                          SIZEWIFI=`expr $SIZE + 32`

                          if [ -e $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab ] && [ $MATLABFILESIZE -gt 0 ]; then

                                  echo "function packet_stat_call()" > $AC_EVALUATIONDIR/packet_stat_call.m
                                  echo "packet_stat($SIZEWIFI, $BITRATE, $INTERVAL, '$NODE.$DEVICE.packets.all.all.matlab', 100, 'packets_stat');"   >> $AC_EVALUATIONDIR/packet_stat_call.m
                                  echo "exit;" >> $AC_EVALUATIONDIR/packet_stat_call.m
                                  echo "end" >> $AC_EVALUATIONDIR/packet_stat_call.m
  
                                  echo "function packet_stat_print_call()" > $AC_EVALUATIONDIR/packet_stat_print_call.m
                                  echo "packet_stat_print('packets_stat');" >> $AC_EVALUATIONDIR/packet_stat_print_call.m
                                  echo "exit;" >> $AC_EVALUATIONDIR/packet_stat_print_call.m
                                  echo "end" >> $AC_EVALUATIONDIR/packet_stat_print_call.m

                                  echo "function packet_stat_paint_call()" > $AC_EVALUATIONDIR/packet_stat_paint_call.m
                                  echo "packet_stat_paint('packets_stat','$NODE.$DEVICE.packets.all.all.matlab');" >> $AC_EVALUATIONDIR/packet_stat_paint_call.m
                                  echo "exit;" >> $AC_EVALUATIONDIR/packet_stat_paint_call.m
                                  echo "end" >> $AC_EVALUATIONDIR/packet_stat_paint_call.m

                                  cp $DIR/packet_stat.m $AC_EVALUATIONDIR/
                                  cp $DIR/packet_stat_print.m $AC_EVALUATIONDIR/
                                  cp $DIR/packet_stat_paint.m $AC_EVALUATIONDIR/

                              if [ "x$MATLAB_AVAILABLE" != "x1" ] && [ "x$REMOTEMATLAB_AVAILABLE" != "x1" ]; then
                                  MATEXT=""

                                  ( cd $AC_EVALUATIONDIR; $LOCALMATLAB -q --funcall packet_stat_call ) > /dev/null 2>&1
                                  ( cd $AC_EVALUATIONDIR; $LOCALMATLAB -q --funcall packet_stat_print_call > $NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab ) > /dev/null 2>&1
                                  #( cd $AC_EVALUATIONDIR; $LOCALMATLAB -q --funcall packet_stat_paint_call ) > /dev/null 2>&1
                              else
                                  MATEXT=".mat"

                                  if [ "x$MATLAB_AVAILABLE" = "x1" ]; then
                                      ( cd $AC_EVALUATIONDIR; $LOCALMATLAB -nodesktop -nojvm -nosplash -r "packet_stat_call;exit" ) > /dev/null 2>&1
                                      ( cd $AC_EVALUATIONDIR; $LOCALMATLAB -nodesktop -nojvm -nosplash -r "packet_stat_print_call;exit" > $NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab ) > /dev/null 2>&1
                                      ( cd $AC_EVALUATIONDIR; $LOCALMATLAB -nodesktop -nojvm -nosplash -r "packet_stat_paint_call;exit" ) > /dev/null 2>&1
                                  else
                                      scp $DIR/packet_stat.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
                                      scp $DIR/packet_stat_print.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
                                      scp $DIR/packet_stat_paint.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
                                      scp $AC_EVALUATIONDIR/$NODE.$DEVICE.packets.all.all.matlab sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
                                      scp $AC_EVALUATIONDIR/packet_stat_call.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
                                      scp $AC_EVALUATIONDIR/packet_stat_print_call.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1
                                      scp $AC_EVALUATIONDIR/packet_stat_paint_call.m sombrutz@gruenau.informatik.hu-berlin.de:~/tmp > /dev/null 2>&1

                                      ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"packet_stat_call;\"" > /dev/null 2>&1
                                      ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"packet_stat_print_call;exit\" > $NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab" > /dev/null 2>&1
                                      ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;/usr/local/bin/matlab -nodesktop -nojvm -nosplash -r \"packet_stat_paint_call;exit\"" > /dev/null 2>&1

                                      scp sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/*.png  $AC_EVALUATIONDIR/ > /dev/null 2>&1
                                      scp sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat_print.matlab  $AC_EVALUATIONDIR/ > /dev/null 2>&1
                                      scp sombrutz@gruenau.informatik.hu-berlin.de:~/tmp/packets_stat$MATEXT  $AC_EVALUATIONDIR/ > /dev/null 2>&1

                                      ssh sombrutz@gruenau.informatik.hu-berlin.de "cd ~/tmp;rm *" > /dev/null 2>&1
                                  fi
                              fi

                              ( cd $AC_EVALUATIONDIR; rm -f  packet_stat_print_call.m packet_stat_call.m packet_stat.m packet_stat_print.m packet_stat_paint.m packet_stat_paint_call.m)
			mv $AC_EVALUATIONDIR/packets_stat$MATEXT $AC_EVALUATIONDIR/$NODE.$DEVICE.$SIZE.$BITRATE.packets_stat.matlab

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
                          else
		          PACKETS_OWN_ALL=0
		          PACKETS_OWN_OK=0
		          PACKETS_OWN_CRC=0
		          PACKETS_OWN_PHY=0
		          MEANPER=1
		          STDPER=1
		          MEANRSSI=0
		          STDRSSI=0
		          FORMEANRSSI=0
		          FORSTDRSSI=0
                              FORRSSI_P5=0
                              FORRSSI_P25=0
                              FORRSSI_P50=0
                              FORRSSI_P75=0
                              FORRSSI_P95=0
                              RSSI_P5=0
                              RSSI_P25=0
                              RSSI_P50=0
                              RSSI_P75=0
                              RSSI_P95=0
		      fi
		
		      if [ -e $DATADIR/$i/$NODE.info ]; then
			LOS=`cat $DATADIR/$i/$NODE.info | grep "LOS" | awk -F= '{print $2}'`
		      else
			LOS=0
		      fi

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
	        
	                echo "$EVALUATIONNUMBER;\"$DATADIR/$i\";" >> $RESULTDIR/info.csv
	
	                EVALUATIONNUMBER=`expr $EVALUATIONNUMBER + 1`
                      done
                  done
              done
	done
    done
done

cat $RESULTDIR/sender.csv.tmp | sort -u > $RESULTDIR/sender.csv
rm -f $RESULTDIR/sender.csv.tmp
cat $RESULTDIR/result.csv | grep -v "NUMBER" | sed -e "s#;# #g" | awk '{print $3"_"$2" "$6" "$7" "$8}' | grep -v "0 0 0" | sort -u > $RESULTDIR/positions.csv
cat $RESULTDIR/sender.csv | sed -e "s#;# #g" | awk '{print $1"_"$2" "$3" "$4" "$5}' | sed -e "s#ath##g" | sort -u >> $RESULTDIR/positions.csv 

cat $RESULTDIR/info.log.tmp | egrep -v "^[[:space:]]*$" > $RESULTDIR/info.log
rm -f $RESULTDIR/info.log.tmp

echo ""

exit 0

