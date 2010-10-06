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

. $CONFIGFILE

if [ "x$EVALUATIONDIR" = "x" ]; then
  EVALUATIONDIR="$RESULTDIR/evaluation"
fi

if [ ! -e $EVALUATIONDIR ]; then
  mkdir -p $EVALUATIONDIR
fi

EXTRAENCAP_FILLER="ATH: (X) Status: 0 (OK) Rate: 0 RSSI: 0 LEN: 0 More: 0 DCErr: 0 Ant: 0 Done: 0 CRCErr: 0 DecryptCRC: 0 (OK) Len: 0 TS: 0 Status: 0 (OK) Rate: 0 RSSI: 0 Ant: 0 Noise: 0 Hosttime: 0 Mactime: 0 Channel: 0 Phyerr: 0 PhyerrStr: (none) More: 0 Keyix: 0 "
GPS_FILLER="0.0 0.0 0.0 0.0 "

for d in `(cd $RESULTDIR;ls *.dump)`; do
    NODENAME=`echo $d | sed "s#\.# #g" | awk '{print $1}'`
    NODEDEVICE=`echo $d | sed "s#\.# #g" | awk '{print $2}'`

    CLICKFILE=`cat $NODETABLE | grep -e "$NODENAME[[:space:]]*$NODEDEVICE" | awk '{print $7}'`
    OUTPUT_FILLER=""

    HASGPS=`cpp $CLICKFILE | egrep -v "^#" | grep "GPSEncap" | wc -l`
    if [ $HASGPS -eq 0 ]; then
      GPS=no
      OUTPUT_FILLER="$OUTPUT_FILLER$GPS_FILLER "
    else
      GPS=yes
    fi

    if [ "x$MODE" = "xsim" ]; then
      OUTPUT_FILLER="$OUTPUT_FILLER$EXTRAENCAP_FILLER"
      ( cd $RESULTDIR; GPS=$GPS SEQ=yes WIFI=extra $DIR/../../bin/fromdump.sh $RESULTDIR/$d | awk -v outfiller=$OUTPUT_FILLER '{print outfiller""$0}' > $EVALUATIONDIR/$d.all.dat )
    else
      WIFIFILE=`cat $NODETABLE | grep "$NODENAME[[:space:]]*$NODEDEVICE" | awk '{print $5}'`

      if [ -f $WIFIFILE ]; then
        . $WIFIFILE
      else
        echo "ERROR while getting WIFIINFOFILE ($WIFIFILE). ABORT!!!"
        exit 1
      fi

      if [ $WIFITYPE -ne 805 ]; then
        OUTPUT_FILLER="$OUTPUT_FILLER$EXTRAENCAP_FILLER"
      fi
      ( cd $RESULTDIR; GPS=$GPS SEQ=yes WIFI=$WIFITYPE $DIR/../../bin/fromdump.sh $RESULTDIR/$d | awk -v outfiller=$OUTPUT_FILLER '{print outfiller""$0}' > $EVALUATIONDIR/$d.all.dat )
    fi
done

exit 0