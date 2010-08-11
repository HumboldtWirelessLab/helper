#!/bin/sh

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

MATLABHOST="gruenau"

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

if [ ! -e evaluation ]; then
    mkdir evaluation
fi

echo -n "" > evaluation/all_bssid.dat
echo -n "" > evaluation/nodes.dat

OUTNODE=`ls *out.dump | head -n 1 | sed "s#\.# #g" | awk '{print $1}'`
OUTDEVICE=`ls *out.dump | head -n 1 | sed "s#\.# #g" | awk '{print $2}'`

if [ "x$OUTNODE" = "x" ] ; then
  OUTMAC=""
else
  OUTMAC=`cat measurement.log | grep -A 4 "Deviceconfig for $OUTNODE:$OUTDEVICE" | grep "Access Point" | awk '{print $6}' | sed "s#:#-#g"`
  echo "outmac: $OUTMAC"
fi

NODELIST=""

for dump in `ls *.dump`; do
    OUT=`echo $dump | grep out | wc -l`
    if [ $OUT -eq 0 ] ; then
	node=`echo $dump | sed "s#\.# #g" | awk '{print $1}'`	
	device=`echo $dump | sed "s#\.# #g" | awk '{print $2}'`

	CHANNEL=`cat measurement.log | grep -A 2 "config $node $device" | grep channel | awk '{print $4}'`
	
	if [ $device = "ath1" ]; then
	    case "$node" in
	      "sk110")
    		node="sk113"
    		;;
	      "sk111")
    		node="sk114"
    		;;
	      "sk112")
    		node="sk115"
    		;;
	    esac      	
	fi

        if [ "x$NODELIST" = "x" ]; then
	  NODELIST="{ '$node'"
	else
	  NODELIST="$NODELIST '$node'"
	fi

if [ ! -e evaluation/processing_done ]; then
	echo "processing $node"
	
	echo "$node $CHANNEL" >> evaluation/nodes.dat
	
	$DIR/../../../bin/fromdump.sh $dump > evaluation/${node}.dat 2>&1
	echo "post-processing $node"
	#cat evaluation/$node.dat | grep "OKPacket:" | awk '{ print $2 "\t" $3 "\t" $5 "\t" $8 "\t" $9 }' | sed -s 's/://g' | sed -s 's/Mb//g' | sed -s 's/mgmt/0/g' | sed -s 's/cntl/1/g' | sed -s 's/data/2/g' > evaluation/${node}_ok.dat
	cat evaluation/$node.dat | grep "OKPacket:" | awk '{ print $2 "\t" $3 "\t" $5 "\t" $8}' | sed -s 's/://g' | sed -s 's/Mb//g' | sed -s 's/mgmt/0/g' | sed -s 's/cntl/1/g' | sed -s 's/data/2/g' > evaluation/${node}_ok.dat
	cat evaluation/$node.dat | grep "CRCerror:" | awk '{ print $2 "\t" $3 "\t" $5 }' | sed -s 's/://g' | sed -s 's/Mb//g' > evaluation/${node}_crc.dat
	cat evaluation/$node.dat | grep "PHYerror:" | awk '{ print $2 "\t" $3 }' | sed -s 's/://g' | sed -s 's/Mb//g' > evaluation/${node}_phy.dat
	cat evaluation/$node.dat | grep "OKPacket:" | grep "mgmt beacon\|mgmt probe_resp" | awk '{ print $10 }' | sort -u  > evaluation/${node}_bssid.dat
	cat evaluation/$node.dat | grep "OKPacket:" | grep "mgmt beacon\|mgmt probe_resp" | awk '{ print $10 }' | sort -u  | wc -l >> evaluation/all_bssid.dat
	if [ "x$OUTMAC" != "x" ]; then
          cat evaluation/$node.dat | grep "OKPacket:" | grep $OUTMAC | awk '{ print $6 }' | sed -s 's/+//g' | awk -F "/" '{ print $1 }' > evaluation/${node}_rssi_ref.dat
	fi
fi
	
    fi
done

touch evaluation/processing_done

NODELIST="$NODELIST }"

echo $NODELIST

MATLABDIR=matlab_$RANDOM

echo "Prepare matlab"
ssh $MATLABHOST "mkdir $MATLABDIR"
echo "Copy Data"
scp $DIR/*.m $MATLABHOST:$MATLABDIR
scp evaluation/* $MATLABHOST:$MATLABDIR

#-nojvm
echo "1"
ssh $MATLABHOST "cd $MATLABDIR; matlab -nodesktop -nosplash -r \"measure_channel_load_all($NODELIST);exit\""
echo "2"
ssh $MATLABHOST "cd $MATLABDIR; matlab -nodesktop -nosplash -r \"measure_channel_load_buckets_all($NODELIST);exit\""

if [ "x$OUTMAC" != "x" ]; then
echo "2"
  ssh $MATLABHOST "cd $MATLABDIR; matlab -nodesktop -nosplash -r \"measure_rssi_ref($NODELIST);exit\""
fi

scp $MATLABHOST:$MATLABDIR/*.eps evaluation/
(cd evaluation/; for i in `ls *.eps`; do epstopdf $i -o=$i.pdf; done)
ssh $MATLABHOST "rm -rf $MATLABDIR"
