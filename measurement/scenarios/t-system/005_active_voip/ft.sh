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

if [ "x$1" = "x" ]; then
    MPREFIX=004
else
    MPREFIX=00$1
fi

DURATION=20
STARTTIME=60
MIDDURATION=40
ENDDURATION=60

MAXNODES=43

#growing_measurement.sh  min_no_of_clients max_no_of_clients step sleeptime startdelay staydelay enddelay

#ORG stuff (SIZE 70, INTERVAL 12, MAXSEQ 500000, BURST 4, ACTIVE true)

if [ -f foreign_node.click.save ]; then
  mv foreign_node.click.save foreign_node.click
fi

mv foreign_node.click foreign_node.click.save

echo "No foreign traffic"
./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-noft



echo "Foreign traffic 10% with cca"

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 93#g" | sed "s#INTERVAL 12#INTERVAL 14#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-10ft_cca


echo "Foreign traffic 10% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-10ft_nocca




echo "Foreign traffic 20% with cca"

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 218#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-20ft_cca

echo "Foreign traffic 20% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-20ft_nocca




echo "Foreign traffic 30% with cca"

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 343#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-30ft_cca

echo "Foreign traffic 30% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-30ft_nocca




echo "Foreign traffic 40% with cca"

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 468#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-40ft_cca

echo "Foreign traffic 40% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-40ft_nocca




echo "Foreign traffic 50% with cca"

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 593#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-50ft_cca

echo "Foreign traffic 50% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 $MPREFIX-50ft_nocca




echo "restore org"

rm -f foreign_node.click
mv foreign_node.click.save foreign_node.click

exit 0
