#!/bin/bash

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

. $DESCRIPTIONFILENAME

WIFICONFIGFILE=`head -n 1 $NODETABLE | awk '{print $5}'`

. $DIR/../../nodes/etc/wifi/default

if [ -f $WIFICONFIGFILE ]; then
	. $WIFICONFIGFILE
else
	if [ -f $CONFIGDIR/$WIFICONFIGFILE ]; then
		. $CONFIGDIR/$WIFICONFIGFILE
	else
		if [ -f $DIR/../../nodes/etc/wifi/$WIFICONFIGFILE ]; then
			. $DIR/../../nodes/etc/wifi/$WIFICONFIGFILE
		fi
	fi
fi

if [ "x$CWMIN" = "x" ]; then
	CWMIN="$DEFAULT_CWMIN"
fi
if [ "x$CWMAX" = "x" ]; then
	CWMAX="$DEFAULT_CWMAX"
fi
if [ "x$AIFS" = "x" ]; then
	AIFS="$DEFAULT_AIFS"
fi

TCLFILE="$RESULTDIR/$NAME.tcl"
exec 3<>$TCLFILE

echo "#Autogenerated" >&3

echo "set brntoolsbase $BRN_TOOLS_PATH" >&3
echo "set nodecount $NODECOUNT" >&3
echo "set single_sensitivity 0" >&3

echo "" >&3

echo "set xsize $POS_X_MAX" >&3
echo "set ysize $POS_Y_MAX" >&3
echo "set stoptime $TIME" >&3

echo "" >&3

if [ "x$SEED" != "x" ]; then
	echo "\$defaultRNG seed $SEED" >&3
	echo "set arrivalRNG [new RNG]" >&3
	echo "set sizeRNG [new RNG]" >&3
	echo "" >&3
fi

if [ "x$DISABLE_NAM" = "x1" ] && [ "x$DISABLE_TR" = "x1" ]; then
  DISABLE_TRACE=1
fi

if [ "x$DISABLE_TRACE" = "x1" ]; then
  DISABLE_NAM=1
  DISABLE_TR=1
  echo "set enable_trace 0" >&3
else
  echo "set enable_trace 1" >&3
fi

if [ "x$DISABLE_TR" = "x1" ]; then
  echo "set enable_tr 0" >&3
else
  echo "set enable_tr 1" >&3
fi
if [ "x$DISABLE_NAM" = "x1" ]; then
  echo "set enable_nam 0" >&3
else
  echo "set enable_nam 1" >&3
fi

echo "set trfilename \"$RESULTDIR/$NAME.tr\"" >&3
echo "set namfilename \"$RESULTDIR/$NAME.nam\"" >&3

echo "" >&3


for hwq in `seq 0 3`; do
	echo $CWMIN | awk -v I=$hwq '{print "Mac/802_11 set CWMin"I"_ "$(I+1)}' | sed "s#0_#_#g" >&3
	echo $CWMAX | awk -v I=$hwq '{print "Mac/802_11 set CWMax"I"_ "$(I+1)}' | sed "s#0_#_#g" >&3
done

echo "Mac/802_11 set NoHWQueues_ 4" >&3

if [ "x$CHANNEL" = "x" ]; then
	CHANNEL=$DEFAULT_CHANNEL
fi
if [ $CHANNEL -lt 15 ]; then
	cat $DIR/../etc/ns/radio/802_11bg.tcl >&3
else
	cat $DIR/../etc/ns/radio/802_11a.tcl >&3
fi

#load default ns2-setting (radiomodel,fading,...)
. $DIR/../etc/ns/radio/default

if [ "x$RADIO" != "x" ]; then
  #TODO: check for predefined radios (tworayground, shadowing, indoor, outdoor
  PATHLOSS=$RADIO
fi

if [ "x$RADIO_OPTIONS" != "x" ]; then
  for i in $RADIO_OPTIONS; do
    eval $i
  done
fi

#avoid loops caused by shadowing using shadowing as channel_model
if [ "x$SHADOWING_PATHLOSS_MODEL" = "xshadowing" ]; then
  SHADOWING_PATHLOSS_MODEL="default"
fi

cat <<EOF >&3

set channel_model "$PATHLOSS"
set fading_model  "$FADING"

set shadowing_pl_exp $PATHLOSS_EXP
set shadowing_std_db $SHADOWING_STD_DB
set shadowing_init_std_db $SHADOWING_INIT_STD_DB

set shadowing_dist0 $shadowing_dist0
set shadowing_seed $shadowing_seed
set shadowing_channel_model $SHADOWING_PATHLOSS_MODEL

set ricean_k $RICEAN_K
set ricean_max_velocity $RICEAN_MAX_VELOCITY

set nakagami_use_dist $nakagami_use_dist

set nakagami_gamma0 $nakagami_gamma0
set nakagami_gamma1 $nakagami_gamma1
set nakagami_gamma2 $nakagami_gamma2

set nakagami_d0_gamma $nakagami_d0_gamma
set nakagami_d1_gamma $nakagami_d1_gamma

set nakagami_m0 $nakagami_m0
set nakagami_m1 $nakagami_m1
set nakagami_m2 $nakagami_m2

set nakagami_d0 $nakagami_d0
set nakagami_d1 $nakagami_d1

EOF

exec 3>&-

$DIR/convert2ns.py --node-list-file=$NODETABLE --node-to-num-map-file=$RESULTDIR/nodes.mac --node-to-position-map-file=$PLMFILE --tcl-file=$TCLFILE >> $TCLFILE

if [ "x$CONTROLFILE" != "x" ]; then
	cat $DIR/../etc/ns/script_01.tcl >> $TCLFILE

	$DIR/decode_ctl.py --control-file="${CONTROLFILE}" --tcl-file="$TCLFILE" --node-list="${NODELIST}" --used-simulator=ns --node-to-click-map-file=$NODETABLE --node-to-num-map-file=$RESULTDIR/nodes.mac

	cat $DIR/../etc/ns/script_02.tcl >> $TCLFILE
else
	cat $DIR/../etc/ns/script_01.tcl $DIR/../etc/ns/script_02.tcl >> $TCLFILE
fi
