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

. $DIR/functions.sh

#GPRMC
gprmc_print() {
#    echo " $1"
    LINE=`echo "$1" | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
#    echo "$LINE"
    TIME=`echo "$LINE" | awk '{print $2}'`
    WARNING=`echo "$LINE" | awk '{print $3}'`
    LATITUDE=`echo "$LINE" | awk '{print $4}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LATITUDE_POST=`echo "$LINE" | awk '{print $5}'`
    LONGITUDE=`echo "$LINE" | awk '{print $6}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LONGITUDE_POST=`echo "$LINE" | awk '{print $7}'`
    SPEED=`echo "$LINE" | awk '{print $8}'`
    COURSE=`echo "$LINE" | awk '{print $9}'`
    DATE=`echo "$LINE" | awk '{print $10}'`
    MAG_DEC=`echo "$LINE" | awk '{print $11}'`
    if [ "x$MAG_DEC" = "x-" ]; then
	MAG_DEC_POST="-"
	MODE=`echo "$LINE" | awk '{print $12}'`
	CHECKSUM=`echo "$LINE" | awk '{print $13}'`
    else
	MAG_DEC_POST=`echo "$LINE" | awk '{print $12}'`
	MODE=`echo "$LINE" | awk '{print $13}'`
	CHECKSUM=`echo "$LINE" | awk '{print $14}'`
    fi
    echo "Date: $DATE $TIME"
    echo "Warning: $WARNING"
    echo "Latitude: $LATITUDE $LATITUDE_POST"
    echo "Longitude: $LONGITUDE $LONGITUDE_POST"
    echo "Speed: $SPEED"
    echo "Course: $COURSE"
    echo "Magnetic Declination: $MAG_DEC $MAG_DEC_POST"
    echo "Mode: $MODE"
    echo "Checksum: $CHECKSUM"
}

#GPGGA
gpgga_print() {
#    echo "$1"
    LINE=`echo "$1" | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
#    echo "$LINE"
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

#PGRME
pgrme_print() {
    LINE=`echo "$1" | sed -e  "s#^.*:.P#P#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
#    echo "$LINE"
    H=`echo "$LINE" | awk '{print $2}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    H_POST=`echo "$LINE" | awk '{print $3}'`
    V=`echo "$LINE" | awk '{print $4}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    V_POST=`echo "$LINE" | awk '{print $5}'`
    S=`echo "$LINE" | awk '{print $6}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    S_POST=`echo "$LINE" | awk '{print $7}'`
    CHECKSUM=`echo "$LINE" | awk '{print $8}'`

    echo "Horizontal: $H $H_POST"
    echo "Vertical: $V $V_POST"
    echo "Sphere: $S $S_POST"
    echo "Checksum: $CHECKSUM"
}

#GPGSA
gpgsa_print() {
    LINE=`echo "$1" | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
    echo "$LINE"
    AUTOSELECT=`echo "$LINE" | awk '{print $2}'`
    KOP=`echo "$LINE" | awk '{print $3}'`
    PDOP=`echo "$LINE" | awk '{print $16}'`
    HDOP=`echo "$LINE" | awk '{print $17}'`
    VDOP=`echo "$LINE" | awk '{print $18}'`
    CHECKSUM=`echo "$LINE" | awk '{print $19}'`

    echo "Autoselection: $AUTOSELECT"
    echo "Kind of Position: $KOP"
    echo "Horizontal: $PDOP"
    echo "Vertical: $HDOP"
    echo "Sphere: $VDOP"
    echo "Checksum: $CHECKSUM"
}

#GPSD
gpsd_print() {
    LINE=`echo "$1" | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
    MODE=`echo "$LINE" | awk '{print $2}'`
    echo "MODE: $MODE"
}


case "$1" in
	"help")
		echo "Use $0 getdata "
		;;
	"rawdata")
		if [ "x$2" = "x" ]; then
		    N=20
		else
		    N=$2
		fi
		gpspipe -t -r -n $N	
		;;
	"getdata")
		while true; do
		    line=`gpspipe -t -r -n 5`
		    echo $line
		    TYPE=`echo $line | grep GPGGA | tail -n 1 | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#,# #g" | awk '{print $1}'`
		    line=`echo $line | grep GPGGA | tail -n 1`
		    echo $TYPE
		    if [ "$TYPE" = "GPGGA" ]; then
			QUAL=`gpgga_print "$line" | grep "Qualtity" | awk '{print $2}'`
			echo $QUAL
			if [ $QUAL -eq 1 ] || [ $QUAL -eq 2 ]; then
		    	    PREC=`gpgga_print "$line" | grep "HDOP" | awk '{print $2}' | sed "s#\..*##g"`
			    echo "Pre: $PREC"
		    	    if [ "x$PREC" != "x" ] && [ $PREC -le 4 ]; then
				gpspipe -t -r -n 15	
				exit 0
			    fi
			fi
		    fi
		done
		;;
	"readdata")
		while read line; do
		    TYPE=`echo $line | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#,# #g" | awk '{print $1}'`
		    if [ "$TYPE" = "GPGGA" ]; then
			QUAL=`gpgga_print "$line" | grep "Qualtity" | awk '{print $2}'`
			if [ $QUAL -eq 1 ] || [ $QUAL -eq 2 ]; then
			    PREC=`gpgga_print "$line" | grep "HDOP" | awk '{print $2}' | sed "s#\..*##g"`
			    if [ "x$PREC" != "x" ] && [ $PREC -le 4 ]; then
				gpgga_print "$line"
				exit 0
			    fi
			fi
		    fi
		done < $2
		;;
	"preparedata")
		while read line; do
		    TYPE=`echo $line | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#,# #g" | awk '{print $1}'`
#		    echo $TYPE
		    case "$TYPE" in
			"GPGGA")
			    gpgga_print "$line"
			    ;;
			"GPGSA")
			    gpgsa_print "$line"
			    ;;
			"GPGSV")
			    #satellites in view
			    #echo "not impl $TYPE"
			    ;;
			"GPRMC")
			    gprmc_print "$line"
			    ;;
			"GPSD")
			    gpsd_print "$line"
			    ;;
			"PGRME")
			    pgrme_print "$line"
			    ;;
			*)
			    ;;
		    esac
		done < $2
		;;
	"getposition")
		BEST=`$0 readdata $2`
		if [ "x$BEST" = "x" ]; then
		    echo "No valid data"
		    exit 0
		fi
		DATE=`echo "$BEST" | grep Time | awk '{print $2}'`
		LAT=`echo "$BEST" | grep Latitude | awk '{print $2}'`
		LATPR=`echo $LAT | sed "s#\.# #g" | awk '{print $1}'`
		LATPO=`echo $LAT | sed "s#\.# #g" | awk '{print $2}'`
		LATPR1=`echo $LATPR | cut -b 1,2`
		LATPR2=`echo $LATPR | cut -b 3,4`
		LATITUDE=`expr $LATPR2$LATPO / 6`
		LONG=`echo "$BEST" | grep Longitude | awk '{print $2}'`
		LONGPR=`echo $LONG | sed "s#\.# #g" | awk '{print $1}'`
		LONGPO=`echo $LONG | sed "s#\.# #g" | awk '{print $2}'`
		LONGPR1=`echo $LONGPR | cut -b 1,2`
		LONGPR2=`echo $LONGPR | cut -b 3,4`
		LONGITUDE=`expr $LONGPR2$LONGPO / 6`
		echo "$DATE $LATPR1.$LATITUDE $LONGPR1.$LONGITUDE"
		;;
	"maps")
		GPS_DATA=`$0 getposition $2`
		echo "$GPS_DATA"
		LATITUDE=`echo "$GPS_DATA" | awk '{print $2}'`
		LONGITUDE=`echo "$GPS_DATA" | awk '{print $3}'`
		URL="http://maps.google.com/maps?t=k&hl=de&ie=UTF8&ll=$LATITUDE,$LONGITUDE&spn=0.001521,0.004442&z=18"
		firefox "$URL"
		;;
  "getgpspos")
    TRY=0;
    
    while [ $TRY -lt 10 ]; do
      LINE=`gpspipe -w -n 5 | grep -E "MID2|GSA" | tail -n 1`
      if [ "x$LINE" != "x"  ]; then
        LAT=`echo $LINE | awk '{print $4}'`
        LONG=`echo $LINE | awk '{print $5}'`
        HEIGHT="0.0"
        echo "$LAT $LONG $HEIGHT"
        exit 0
      fi
      TRY=`expr $TRY + 1`
    done
    echo "0.0 0.0 0.0"
    ;;
	"help")
		echo "Take a look at http://www.kowoma.de/gps/zusatzerklaerungen/NMEA.htm"
		;;
	*)
		$0 help
		;;
esac

exit 0		
