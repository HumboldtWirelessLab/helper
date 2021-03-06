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
    LINE=`echo "$1" | sed -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
#    echo "$LINE"
    TIME=`echo "$LINE" | awk '{print $2}' | sed -e "s#:\\$##g"`
    LATITUDE=`echo "$LINE" | awk '{print $5}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LATITUDE_POST=`echo "$LINE" | awk '{print $6}'`
    LONGITUDE=`echo "$LINE" | awk '{print $7}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    LONGITUDE_POST=`echo "$LINE" | awk '{print $8}'`
    QUALITY=`echo "$LINE" | awk '{print $9}'`
    SATELLITES=`echo "$LINE" | awk '{print $10}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
    HDOP=`echo "$LINE" | awk '{print $11}'`
    HOG=`echo "$LINE" | awk '{print $12}'`
    HOG_POST=`echo "$LINE" | awk '{print $13}'`
    HGM=`echo "$LINE" | awk '{print $14}'`
    HGM_POST=`echo "$LINE" | awk '{print $15}'`
    EMPTY=`echo "$LINE" | awk '{print $16}'`
    CHECKSUM=`echo "$LINE" | awk '{print $17}'`

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

gps_calc() {
    PR=`echo $1 | sed "s#\.# #g" | awk '{print $1}'`
    PO=`echo $1 | sed "s#\.# #g" | awk '{print $2}'`
    PR1=`echo $PR | cut -b 1,2`
    PR2=`echo $PR | cut -b 3,4`
    #       POC=`calc $PR2$PO / 6  | sed -e "s#~##g" | awk '{print $1}' | sed "s#\.##g"`
    POC=`echo "print ($PR2$PO / 6);" | perl | sed -e "s#~##g" | awk '{print $1}' | sed "s#\.##g" | cut -b 1-6`
    echo "$PR1.$POC"
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
		    line=`gpspipe -t -r -n 10 | grep -v class | grep GPGGA | tail -n 1`
		    #echo $line
		    TYPE=`echo $line | sed "s#,# #g" | awk '{print $3}' | sed -e "s#^.G#G#g"`
		    #echo $TYPE
		    if [ "$TYPE" = "GPGGA" ]; then
		        #gpgga_print "$line"
			QUAL=`gpgga_print "$line" | grep "Qualtity" | awk '{print $2}'`
			#echo $QUAL
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
qq		LONGPO=`echo $LONG | sed "s#\.# #g" | awk '{print $2}'`
		LONGPR1=`echo $LONGPR | cut -b 1,2`
		LONGPR2=`echo $LONGPR | cut -b 3,4`
		LONGITUDE=`expr $LONGPR2$LONGPO / 6`
		echo "$DATE $LATPR1.$LATITUDE $LONGPR1.$LONGITUDE"
		;;
	"maps")
		#GPS_DATA=`$0 getposition $2`
		#echo "$GPS_DATA"
		#LATITUDE=`echo "$GPS_DATA" | awk '{print $2}'`
		#LONGITUDE=`echo "$GPS_DATA" | awk '{print $3}'`
		GPS_DATA=`$0 getgpspos $2`
		echo "$GPS_DATA"
		LATITUDE=`echo "$GPS_DATA" | awk '{print $1}'`
		LONGITUDE=`echo "$GPS_DATA" | awk '{print $2}'`
		URL="http://maps.google.com/maps?t=k&hl=de&ie=UTF8&ll=$LATITUDE,$LONGITUDE&spn=0.001521,0.004442&z=18"
		firefox "$URL"
		;;
  "getgpspos")
    HASGPS=0
    for d in /dev/ttyUSB0 /dev/ttyACM0; do
      #TESTGPS=`gpsctl $d 2>&1 | grep "at" | sed -e "s#^.*at##g" | awk '{print $1}'`
      TESTGPS=`gpsctl 2>&1 | grep -v "(null)" | wc -l`
       #echo "$d $TESTGPS"
      if [ "x$TESTGPS" != "x0" ] && [ "x$TESTGPS" != "x" ]; then
        HASGPS=1
      fi
    done

    if [ "x$GPSFILE" != "x" ]; then
      HASGPS=1
    fi

    if [ "x$HASGPS" = "x0" ]; then
      if [ "x$GPSTIME" = "xyes" ]; then
        echo "0.0 0.0 0.0 0.0 0.0"
      else
        echo "0.0 0.0 0.0 0.0"
      fi
      exit 0
    fi

    if [ "x$MAXTRY" = "x" ]; then
      MAXTRY=5
    fi
    TRY=0;

    while [ $TRY -lt $MAXTRY ]; do
      if [ "x$GPSFILE" != "x" ]; then
        LINE=`cat $GPSFILE | grep -E "MID2|GSA|TPV" | tail -n 1`
      else
        LINE=`gpspipe -w -n 7 | grep -E "MID2|GSA|TPV" | tail -n 1`
      fi
      if [ "x$LINE" != "x"  ]; then
        NEWGPSD=`echo $LINE | grep "class" | wc -l`
        if [ $NEWGPSD -eq 0 ]; then
          #old gps-tools
          LAT=`echo $LINE | awk '{print $4}'`
          LONG=`echo $LINE | awk '{print $5}'`
          ALT="0.0"
          SPEED="0.0"
          TIME="0.0"
          if [ "x$GPSTIME" = "xyes" ]; then
            echo "$LAT $LONG $ALT $SPEED $TIME"
          else
            echo "$LAT $LONG $ALT $SPEED"
          fi
          exit 0
        else
          VALID=`echo $LINE | grep "lat" | wc -l`
          if [ $VALID -eq 1 ]; then
            #new gps-tools
            LAT=`echo $LINE | sed "s#:# #g" | sed "s#,# #g" | awk '{print $16}'`
            LONG=`echo $LINE | sed "s#:# #g" | sed "s#,# #g" | awk '{print $18}'`
            ALT=`echo $LINE | sed "s#:# #g" | sed "s#,# #g" | awk '{print $20}'`
            SPEED=`echo $LINE | sed "s#:# #g" | sed "s#,# #g" | awk '{print $30}'`
            LATH=`echo $LAT | sed "s#\.# #g" | awk '{print $1}'`
            LATL=`echo $LAT | sed "s#\.# #g" | awk '{print $2}' | cut -b 1-6`
            LONGH=`echo $LONG | sed "s#\.# #g" | awk '{print $1}'`
            LONGL=`echo $LONG | sed "s#\.# #g" | awk '{print $2}' | cut -b 1-6`
            ALTH=`echo $ALT | sed "s#\.# #g" | awk '{print $1}'`
            ALTL=`echo $ALT | sed "s#\.# #g" | awk '{print $2}' | cut -b 1-6`
            SPEEDH=`echo $SPEED | sed "s#\.# #g" | awk '{print $1}'`
            SPEEDL=`echo $SPEED | sed "s#\.# #g" | awk '{print $2}' | cut -b 1-6`

            TIME=`echo $LINE | sed "s#,# #g" | awk '{print $5}' | sed 's#"time":"##g' | sed 's#\.[0-9]*Z"##g'`

            LAT="$LATH.$LATL"
            if [ $LAT != "." ]; then
              LONG="$LONGH.$LONGL"
              HEIGHT="$ALTH.$ALTL"
              SPEED="$SPEEDH.$SPEEDL"
              if [ $LATH -ne 180 ]; then
                if [ "x$GPSTIME" = "xyes" ]; then
                  echo "$LAT $LONG $HEIGHT $SPEED $TIME"
                else
                  echo "$LAT $LONG $HEIGHT $SPEED"
                fi
                exit 0
              fi
            fi
          fi
        fi
      fi
      TRY=`expr $TRY + 1`
    done
    if [ "x$GPSTIME" = "xyes" ]; then
      echo "0.0 0.0 0.0 0.0 0.0"
    else
      echo "0.0 0.0 0.0 0.0"
    fi
    ;;
  "getgpsposraw")
    HASGPS=0
    GPSFILE=""
    for d in /dev/ttyUSB0 /dev/ttyACM0 /dev/ttyACM1; do
      if [ -e $d ]; then
        GPSFILE=$d
      fi
    done

#   echo ">$GPSFILE<"
    if [ "x$GPSFILE" != "x" ]; then
      GGA=`head -n 10 $GPSFILE | grep GPGGA | tail -n 1`
      #    echo "$1"
      LINE=`echo "$GGA" | sed -e  "s#^.*:.G#G#g" -e "s#^.*:.PG#PG#g" -e "s#^.*:G#G#g" -e "s#\*#,#g" | sed -e "s#,,#,-,#g" -e "s#,,#,-,#g" -e "s#,# #g" `
#    echo "$LINE"
      TIME=`echo "$LINE" | awk '{print $2}'`
      LATITUDE=`echo "$LINE" | awk '{print $3}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
      LAT=`gps_calc $LATITUDE`
      LONGITUDE=`echo "$LINE" | awk '{print $5}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
      LONG=`gps_calc $LONGITUDE`
      HOG=`echo "$LINE" | awk '{print $10}'`
      SATELLITES=`echo "$LINE" | awk '{print $8}' | sed "s#^[0]*##g" | sed "s#^\.#0.#g"`
      HDOP=`echo "$LINE" | awk '{print $9}'`
      HGM=`echo "$LINE" | awk '{print $12}'`
    else
      LAT=0.0
      LONG=0.0
      HOG=0.0
    fi

    if [ "x$GPSTIME" = "xyes" ]; then
      echo "$LAT $LONG $HOG 0.0 0.0"
    else
      echo "$LAT $LONG $HOG 0.0"
    fi
    ;;
    "getgpsposloop")
    while true; do
      GPSTIME=yes $0 getgpspos
    done
    ;;
	"help")
		echo "Take a look at http://www.kowoma.de/gps/zusatzerklaerungen/NMEA.htm"
		;;
	*)
		$0 help
		;;
esac

exit 0
