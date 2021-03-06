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

if [ -e $DIR/../../bin/functions.sh ]; then
  . $DIR/../../bin/functions.sh
fi

echo -n "" > all_bssid.dat
echo -n "" > nodes.dat
echo -n "" > all_seq_no.dat

rm -f all_seq_no.dat.tmp

OUTDUMPS=`ls *out.dump.all.dat 2> /dev/null`
OUTNODES=""

for od in $OUTDUMPS; do
  OUTNODE=`echo $od | sed "s#\.# #g" | awk '{print $1}'`
  OUTDEVICE=`echo $od | sed "s#\.# #g" | awk '{print $2}'`
  OUTMACS=`cat $od | grep "Sequence" | awk '{print $10$11}' | cut -b 5-16  | uniq`

  echo -n "" > outmacs.dat

  for om in $OUTMACS; do
    FORMATEDMAC=`echo $om | awk '{print substr($1,1,2)"-"substr($1,3,2)"-"substr($1,5,2)"-"substr($1,7,2)"-"substr($1,9,2)"-"substr($1,11,2)}'`
    SINGLEOUTMAC=$FORMATEDMAC
    echo "$OUTNODE $OUTDEVICE $FORMATEDMAC" >> outmacs.dat
  done

  NEWOUTNODE=`cat $od | grep "Sequence" | awk '{print $9" "$10" "$11}' | uniq`
  OUTNODES="$OUTNODES $NEWOUTNODE"
done

NODEDEVLIST=""
NODENUMBER=1

for dump in `ls *.dump.all.dat 2> /dev/null`; do
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

#offset 6 -> 67
    cat $dump | grep "OKPacket:" | awk '{ print $69 "\t" $70 "\t" $72 "\t" $75}' | sed -s 's/://g' | sed -s 's/Mb//g' | sed -s 's/mgmt/0/g' | sed -s 's/cntl/1/g' | sed -s 's/data/2/g' > $BASEFILE.ok.dat
    cat $dump | grep "CRCerror:" | awk '{ print $69 "\t" $70 "\t" $72 }' | sed -s 's/://g' | sed -s 's/Mb//g' > $BASEFILE.crc.dat
    cat $dump | grep "PHYerror:" | awk '{ print $69 "\t" $70 }' | sed -s 's/://g' | sed -s 's/Mb//g' >  $BASEFILE.phy.dat
    cat $dump | grep "OKPacket:" | grep "mgmt beacon\|mgmt probe_resp" | awk '{ print $75 }' | uniq  >  $BASEFILE.bssid.dat
    cat $BASEFILE.bssid.dat | wc -l >> all_bssid.dat

    if [ "x$SINGLEOUTMAC" != "x" ]; then
            cat $dump | grep "OKPacket:" | grep -i $SINGLEOUTMAC | awk '{ print $73 }' | sed -s 's/+//g' | awk -F "/" '{ print $1 }' >  $BASEFILE.rssi_ref.dat
    fi

    cat $dump | grep "Sequence:" | awk '{ print $6"\tSRCMAC" $10$11 "\t" $13 }' | sed "s#SRCMACffff##g" | sed "s#:##g" >>  $BASEFILE.seq_no.dat.tmp
    cat $BASEFILE.seq_no.dat.tmp | awk '{print $2" "$3}'>> all_seq_no.dat.tmp
    cat $BASEFILE.seq_no.dat.tmp | awk '{print $1"\t"$2"\t"strtonum("0x"$3)}' >> $BASEFILE.seq_no.dat

    rm $BASEFILE.seq_no.dat.tmp

    #cat $dump | grep "Sequence:" | awk '{ print $6"\tSRCMAC" $10$11 "\t" $13 }' |  sed "s#SRCMACffff##g" | sed "s#:##g" | head -n15 | awk -v nodeid="$nodeid" '{ print nodeid "\t" $2 "\t" $5}' | awk --non-decimal-data '{print $1 "\t" $2 "\t" $3 "\t" ("0x"$4)+0 }' | sed -s 's/://g' >> sync.dat

    cat $dump | grep -P "OKPacket:" | grep -P "retry" | awk '{ print $69 "\t" $70 "\t" $72 "\t" $75}' | sed -s 's/://g' | sed -s 's/Mb//g' | sed -s 's/mgmt/0/g' | sed -s 's/cntl/1/g' | sed -s 's/data/2/g' > $BASEFILE.retry.dat

    NODENUMBER=`expr $NODENUMBER + 1`
  fi
done

cat all_seq_no.dat.tmp | uniq | awk '{print $1" "strtonum("0x"$2)}' > all_seq_no.dat
rm -f all_seq_no.dat.tmp

touch processing_done

NODEDEVLIST="$NODEDEVLIST }"

DEBUGDEV=./matlab.log

#echo $NODEDEVLIST

echo "Copy Data"
cp $DIR/*.m .

echo "Channel load all"
matwrapper "try,measure_channel_load_all($NODEDEVLIST),catch,exit(1),end,exit(0)" >> $DEBUGDEV 2>&1

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi

echo "Channel load buckets"
matwrapper "try,measure_channel_load_buckets_all($NODEDEVLIST),catch,exit(1),end,exit(0)" >> $DEBUGDEV 2>&1

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi

if [ "x$SINGLEOUTMAC" != "x" ]; then
  echo "RSSI Ref"
  matwrapper "try,measure_rssi_ref($NODEDEVLIST),catch,exit(1),end,exit(0)" >> $DEBUGDEV 2>&1

  if [ $? -ne 0 ]; then
    echo "Ohh, matlab error."
  fi
fi

for i in `ls *.eps`; do epstopdf $i -o=$i.pdf; done
