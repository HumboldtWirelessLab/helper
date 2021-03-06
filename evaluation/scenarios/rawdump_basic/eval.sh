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

EXTRAENCAP_FILLER="ATH: (X) Status: 0 (OK) Rate: 0 RSSI: 0 LEN: 0 More: 0 DCErr: 0 Ant: 0 Done: 0 CRCErr: 0 DecryptCRC: 0 (OK) Len: 0 TS: 0 Status: 0 (OK) Rate: 0 RSSI: 0 Ant: 0 Noise: 0 Hosttime: 0 Mactime: 0 Channel: 0 ChannelUtility: 0 DriverFlags: 0 Flags: 0 Phyerr: 0 PhyerrStr: (none) More: 0 Keyix: 0 "
GPS_FILLER="LAT: 0.0 LONG: 0.0 ALT: 0.0 SPEED: 0.0 "

echo $RESULTDIR
(cd $RESULTDIR;ls *.dump)

for d in `(cd $RESULTDIR;ls *.dump)`; do
echo "bla"
    NODENAME=`echo $d | sed "s#\.# #g" | awk '{print $1}'`
    NODEDEVICE=`echo $d | sed "s#\.# #g" | awk '{print $2}'`

    CLICKFILE=`cat $NODETABLE | grep -e "$NODENAME[[:space:]]*$NODEDEVICE" | awk '{print $7}'`
    OUTPUT_FILLER=""

echo "k $CLICKFILE"
    HASGPS=`cat $CLICKFILE | egrep -v "^#" | grep "GPSEncap" | wc -l`
    if [ $HASGPS -eq 0 ]; then
      GPS=no
      OUTPUT_FILLER="$OUTPUT_FILLER$GPS_FILLER "
    else
      GPS=yes
    fi

echo "foo"
    if [ "x$MODE" = "xsim" ]; then
      echo "eval dump"
      OUTPUT_FILLER="$OUTPUT_FILLER$EXTRAENCAP_FILLER"
      echo "$OUTPUT_FILLER"
      ( cd $RESULTDIR; GPS=$GPS SEQ=yes $DIR/../../bin/fromdump.sh $RESULTDIR/$d | awk -v outfiller="$OUTPUT_FILLER" '{print outfiller""$0}' > $EVALUATIONDIR/$d.all.dat )
      echo "fine"
    else
      WIFITYPE=`testheader.sh $RESULTDIR/$d`
      if [ $WIFITYPE -ne 805 ]; then
        OUTPUT_FILLER="$OUTPUT_FILLER$EXTRAENCAP_FILLER"
      fi
      ( cd $RESULTDIR; GPS=$GPS SEQ=yes $DIR/../../bin/fromdump.sh $RESULTDIR/$d | awk -v outfiller="$OUTPUT_FILLER" '{print outfiller""$0}' > $EVALUATIONDIR/$d.all.dat )
    fi
done

exit 0

