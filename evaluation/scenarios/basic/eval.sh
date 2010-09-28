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

for d in `(cd $RESULTDIR;ls *.dump)`; do
    NODENAME=`echo $d | sed "s#\.# #g" | awk '{print $1}'`
    NODEDEVICE=`echo $d | sed "s#\.# #g" | awk '{print $2}'`

    CLICKFILE=`cat $NODETABLE | grep -e "$NODENAME[[:space:]]*$NODEDEVICE" | awk '{print $7}'`

    HASGPS=`cpp $CLICKFILE | egrep -v "^#" | grep "GPSEncap" | wc -l`
    if [ $HASGPS -eq 0 ]; then
      GPS=no
    else
      GPS=yes
    fi

    if [ "x$MODE" = "xsim" ]; then
      if [ $GPS = "yes" ]; then
        ( cd $RESULTDIR; GPS=$GPS SEQ=yes WIFI=extra $DIR/../../bin/fromdump.sh $RESULTDIR/$d > $EVALUATIONDIR/$d.all.dat )
      else
        ( cd $RESULTDIR; GPS=$GPS SEQ=yes WIFI=extra $DIR/../../bin/fromdump.sh $RESULTDIR/$d | awk '{print "0.0 0.0 0.0 0.0 "$0}' > $EVALUATIONDIR/$d.all.dat )
      fi	
    else
      WIFIFILE=`cat $NODETABLE | grep "$NODENAME[[:space:]]*$NODEDEVICE" | awk '{print $5}'`

      if [ -f $WIFIFILE ]; then
        . $WIFIFILE
      else
        echo "ERROR while getting WIFIINFOFILE ($WIFIFILE). ABORT!!!"
        exit 1
      fi

      if [ $GPS = "yes" ]; then
        ( cd $RESULTDIR; GPS=$GPS SEQ=yes WIFI=$WIFITYPE $DIR/../../bin/fromdump.sh $RESULTDIR/$d > $EVALUATIONDIR/$d.all.dat )
      else
        ( cd $RESULTDIR; GPS=$GPS SEQ=yes WIFI=$WIFITYPE $DIR/../../bin/fromdump.sh $RESULTDIR/$d | awk '{print "0.0 0.0 0.0 0.0 "$0}' > $EVALUATIONDIR/$d.all.dat )
      fi
    fi
done

exit 0