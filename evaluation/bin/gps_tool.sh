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

#GPGGA
gpgga_print() {
    LINE=`echo "$1" | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
    LATITUDE=`echo "$LINE" | awk '{print $3}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LATITUDE_POST=`echo "$LINE" | awk '{print $4}'`
    LONGITUDE=`echo "$LINE" | awk '{print $5}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LONGITUDE_POST=`echo "$LINE" | awk '{print $6}'`
    QUALITY=`echo "$LINE" | awk '{print $7}'`
    HOG=`echo "$LINE" | awk '{print $10}'`
    HOG_POST=`echo "$LINE" | awk '{print $11}'`
    CHECKSUM=`echo "$LINE" | awk '{print $16}'`

    echo "Latitude: $LATITUDE $LATITUDE_POST"
    echo "Longitude: $LONGITUDE $LONGITUDE_POST"
    echo "Qualtity: $QUALITY"
    echo "HOG: $HOG $HOG_POST"
}

gps_calc() {
	PR=`echo $1 | sed "s#\.# #g" | awk '{print $1}'`
	PO=`echo $1 | sed "s#\.# #g" | awk '{print $2}'`
	PR1=`echo $PR | cut -b 1,2`
	PR2=`echo $PR | cut -b 3,4`
#	POC=`calc $PR2$PO / 6  | sed -e "s#~##g" | awk '{print $1}' | sed "s#\.##g"`
	POC=`$DIR/perl_calc.pl $PR2$PO  6  | sed -e "s#~##g" | awk '{print $1}' | sed "s#\.##g"`
	echo "$PR1.$POC"
}


case "$1" in 
	"getdistance")
		    	LAT=0
			LONG=0
			HOG=0
			SENDERLAT=0
			SENDERLONG=0
			SENDERHOG=0

			if [ -e $2 ];	then
				GPSDATARAW=`cat $2 | grep GPGGA | tail -n 1`
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

			if [ -e $3 ];	then
				GPSDATARAW=`cat $3 | grep GPGGA | tail -n 1`
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
				DISTANCE=`(cd $DIR;java GeoParser $LONG $LAT $SENDERLONG $SENDERLAT)`
			else
				DISTANCE="-1"
			fi

			echo "$DISTANCE"

			;;
	"getposition")
		    	LAT=0
			LONG=0
			HOG=0

			if [ -e $2 ];	then
				GPSDATARAW=`cat $2 | grep GPGGA | tail -n 1`
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

			echo "$LAT $LONG $HOG"; 

			;;
	"help")
		echo "Use $0 [getposition FILE] | [getdistance FILE1 FILE2] !"
		;; 
	"*")
		$0 help
		;;

esac

exit 0

