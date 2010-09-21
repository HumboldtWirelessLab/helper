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
  OUTMACS=`cat $od | grep "Sequence" | awk '{print $6$7}' | cut -b 5-16  | sort -u`

  for om in $OUTMACS; do
    FORMATEDMAC=`echo $om | awk '{print substr($1,1,2)"-"substr($1,3,2)"-"substr($1,5,2)"-"substr($1,7,2)"-"substr($1,9,2)"-"substr($1,11,2)}'`
    SINGLEOUTMAC=$FORMATEDMAC
    echo "$OUTNODE $OUTDEVICE $FORMATEDMAC" >> outmacs.dat
  done

  NEWOUTNODE=`cat $od | grep "Sequence" | awk '{print $5" "$6" "$7}' | sort -u`
  OUTNODES="$OUTNODES $NEWOUTNODE"
done

NODELIST=""

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
	
	#TODO: remove remapping
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

	echo "processing $dump"
	echo "$node $CHANNEL" >> nodes.dat
	
	BASEFILE=`echo $dump | sed "s#.all.dat##g"`
	
	cat $dump | grep "OKPacket:" | awk '{ print $2 "\t" $3 "\t" $5 "\t" $8}' | sed -s 's/://g' | sed -s 's/Mb//g' | sed -s 's/mgmt/0/g' | sed -s 's/cntl/1/g' | sed -s 's/data/2/g' > $BASEFILE.ok.dat
	cat $dump | grep "CRCerror:" | awk '{ print $2 "\t" $3 "\t" $5 }' | sed -s 's/://g' | sed -s 's/Mb//g' > $BASEFILE.crc.dat
	cat $dump | grep "PHYerror:" | awk '{ print $2 "\t" $3 }' | sed -s 's/://g' | sed -s 's/Mb//g' >  $BASEFILE.phy.dat
	cat $dump | grep "OKPacket:" | grep "mgmt beacon\|mgmt probe_resp" | awk '{ print $10 }' | sort -u  >  $BASEFILE.bssid.dat
	cat $dump | grep "OKPacket:" | grep "mgmt beacon\|mgmt probe_resp" | awk '{ print $10 }' | sort -u  | wc -l >> all_bssid.dat
	
	if [ "x$SINGLEOUTMAC" != "x" ]; then
          cat $dump | grep "OKPacket:" | grep $SINGLEOUTMAC | awk '{ print $6 }' | sed -s 's/+//g' | awk -F "/" '{ print $1 }' >  $BASEFILE.rssi_ref.dat
 	fi
	  
	cat $dump | grep "Sequence:" | awk '{ print $2"\tSRCMAC" $6$7 "\t" $9 }' | sed "s#SRCMACffff##g" | sed "s#:##g" >>  $BASEFILE.seq_no.dat.tmp
	cat $BASEFILE.seq_no.dat.tmp | awk '{print $2" "$3}'>> all_seq_no.dat.tmp
        cat $BASEFILE.seq_no.dat.tmp | awk '{print $1"\t"$2"\t"strtonum("0x"$3)}' >> $BASEFILE.seq_no.dat
	rm $BASEFILE.seq_no.dat.tmp
    fi
done

cat all_seq_no.dat.tmp | sort -u | awk '{print $1" "strtonum("0x"$2)}' > all_seq_no.dat
rm -f all_seq_no.dat.tmp

touch processing_done

NODELIST="$NODELIST }"

which matlab > /dev/null

if [ $? -ne 0 ]; then
  echo "No matlab. Abort evaluation."
  exit 0
fi

echo $NODELIST

echo "Copy Data"
cp $DIR/*.m .

echo "Channel load all"
matlab -nodesktop -nosplash -r "try,measure_channel_load_all($NODELIST),catch,exit(1),end,exit(0)"

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi

echo "Channel load buckets"
matlab -nodesktop -nosplash -r "try,measure_channel_load_buckets_all($NODELIST),catch,exit(1),end,exit(0)"

if [ $? -ne 0 ]; then
  echo "Ohh, matlab error."
fi

if [ "x$SINGLEOUTMAC" != "x" ]; then
  echo "RSSI Ref"
  matlab -nodesktop -nosplash -r "try,measure_rssi_ref($NODELIST),catch,exit(1),end,exit(0)"

  if [ $? -ne 0 ]; then
    echo "Ohh, matlab error."
  fi
fi

for i in `ls *.eps`; do epstopdf $i -o=$i.pdf; done

#
#MATLABDIR=matlab_$RANDOM

#echo "Prepare matlab"
#ssh $MATLABHOST "mkdir $MATLABDIR"
#echo "Copy Data"
#cp $DIR/*.m $MATLABHOST:$MATLABDIR
#scp evaluation/* $MATLABHOST:$MATLABDIR

#-nojvm
#echo "1"
#ssh $MATLABHOST "cd $MATLABDIR; matlab -nodesktop -nosplash -r \"measure_channel_load_all($NODELIST);exit\""
#echo "2"
#ssh $MATLABHOST "cd $MATLABDIR; matlab -nodesktop -nosplash -r \"measure_channel_load_buckets_all($NODELIST);exit\""

#if [ "x$OUTMAC" != "x" ]; then
#echo "2"
#  ssh $MATLABHOST "cd $MATLABDIR; matlab -nodesktop -nosplash -r \"measure_rssi_ref($NODELIST);exit\""
#fi

#scp $MATLABHOST:$MATLABDIR/*.eps evaluation/
#(cd evaluation/; for i in `ls *.eps`; do epstopdf $i -o=$i.pdf; done)
#ssh $MATLABHOST "rm -rf $MATLABDIR"
