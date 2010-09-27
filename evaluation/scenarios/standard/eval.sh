#!/bin/sh

dir=$(dirname "$0")
pwd=$(pwd)

SIGN=`echo $dir | cut -b 1`

MATLABHOST="localhost"

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

echo -n "" > all_bssid.dat
echo -n "" > nodes.dat
echo -n "" > all_seq_no.dat

rm -f all_seq_no.dat.tmp

OUTDUMPS=`ls *out.dump.all.dat`
OUTNODES=""

for od in $OUTDUMPS; do
  OUTNODE=`echo $od | sed "s#\.# #g" | awk '{print $1}'`
  OUTDEVICE=`echo $od | sed "s#\.# #g" | awk '{print $2}'`
  OUTMACS=`cat $od | grep "Sequence" | awk '{print $10$11}' | cut -b 5-16  | sort -u`

  for om in $OUTMACS; do
    FORMATEDMAC=`echo $om | awk '{print substr($1,1,2)"-"substr($1,3,2)"-"substr($1,5,2)"-"substr($1,7,2)"-"substr($1,9,2)"-"substr($1,11,2)}'`
    SINGLEOUTMAC=$FORMATEDMAC
    echo "$OUTNODE $OUTDEVICE $FORMATEDMAC" >> outmacs.dat
  done

  NEWOUTNODE=`cat $od | grep "Sequence" | awk '{print $9" "$10" "$11}' | sort -u`
  OUTNODES="$OUTNODES $NEWOUTNODE"
done

NODEDEVLIST=""

for dump in `ls *.dump.all.dat`; do
    OUT=`echo $dump | grep out | wc -l`
    if [ $OUT -eq 0 ] ; then
	node=`echo $dump | sed "s#\.# #g" | awk '{print $1}'`	
	device=`echo $dump | sed "s#\.# #g" | awk '{print $2}'`

        if [ -f $RESULTDIR/measurement.log ]; then 
	  CHANNEL=`cat $RESULTDIR/measurement.log | grep -A 2 "config $node $device" | grep channel | awk '{print $4}'`
	  if [ "x$CHANNEL" = "x" ]; then
	    CHANNEL=1
          fi
	else
	  CHANNEL=1
	fi
	
        if [ "x$NODEDEVLIST" = "x" ]; then
	  NODEDEVLIST="{ '$node.$device'"
	else
	  NODEDEVLIST="$NODEDEVLIST '$node.$device'"
	fi

	echo "processing $dump"
	echo "$node $CHANNEL" >> nodes.dat
	
	BASEFILE=`echo $dump | sed "s#.all.dat##g"`
	
	cat $dump | grep "OKPacket:" | awk '{ print $6 "\t" $7 "\t" $9 "\t" $12}' | sed -s 's/://g' | sed -s 's/Mb//g' | sed -s 's/mgmt/0/g' | sed -s 's/cntl/1/g' | sed -s 's/data/2/g' > $BASEFILE.ok.dat
	cat $dump | grep "CRCerror:" | awk '{ print $6 "\t" $7 "\t" $9 }' | sed -s 's/://g' | sed -s 's/Mb//g' > $BASEFILE.crc.dat
	cat $dump | grep "PHYerror:" | awk '{ print $6 "\t" $7 }' | sed -s 's/://g' | sed -s 's/Mb//g' >  $BASEFILE.phy.dat
	cat $dump | grep "OKPacket:" | grep "mgmt beacon\|mgmt probe_resp" | awk '{ print $14 }' | sort -u  >  $BASEFILE.bssid.dat
	cat $dump | grep "OKPacket:" | grep "mgmt beacon\|mgmt probe_resp" | awk '{ print $14 }' | sort -u  | wc -l >> all_bssid.dat
	
	if [ "x$SINGLEOUTMAC" != "x" ]; then
          cat $dump | grep "OKPacket:" | grep -i $SINGLEOUTMAC | awk '{ print $10 }' | sed -s 's/+//g' | awk -F "/" '{ print $1 }' >  $BASEFILE.rssi_ref.dat
 	fi
	  
	cat $dump | grep "Sequence:" | awk '{ print $6"\tSRCMAC" $10$11 "\t" $13 }' | sed "s#SRCMACffff##g" | sed "s#:##g" >>  $BASEFILE.seq_no.dat.tmp
	cat $BASEFILE.seq_no.dat.tmp | awk '{print $2" "$3}'>> all_seq_no.dat.tmp
        cat $BASEFILE.seq_no.dat.tmp | awk '{print $1"\t"$2"\t"strtonum("0x"$3)}' >> $BASEFILE.seq_no.dat
	rm $BASEFILE.seq_no.dat.tmp
    fi
done

cat all_seq_no.dat.tmp | sort -u | awk '{print $1" "strtonum("0x"$2)}' > all_seq_no.dat
rm -f all_seq_no.dat.tmp

touch processing_done

NODEDEVLIST="$NODEDEVLIST }"

which matlab > /dev/null

if [ $? -ne 0 ]; then
  echo "No matlab. Try octave."
  which octave > /dev/null
  if [ $? -ne 0 ]; then
    echo "No octave. Abort evaluation."
    exit 0
  else
    MATLAB="octave --eval"
  fi
else
  MATLAB="matlab -nodesktop -nosplash -r"
fi

DEBUGDEV=./matlab.log

#echo $NODEDEVLIST

echo "Copy Data"
cp $DIR/*.m .

echo "Channel load all"
${MATLAB} "try,measure_channel_load_all($NODEDEVLIST),catch,exit(1),end,exit(0)" >> $DEBUGDEV 2>&1

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi

echo "Channel load buckets"
${MATLAB} "try,measure_channel_load_buckets_all($NODEDEVLIST),catch,exit(1),end,exit(0)" >> $DEBUGDEV 2>&1

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi

if [ "x$SINGLEOUTMAC" != "x" ]; then
  echo "RSSI Ref"
  ${MATLAB} "try,measure_rssi_ref($NODEDEVLIST),catch,exit(1),end,exit(0)" >> $DEBUGDEV 2>&1

  if [ $? -ne 0 ]; then
    echo "Ohh, matlab error."
  fi
fi

for i in `ls *.eps`; do epstopdf $i -o=$i.pdf; done
