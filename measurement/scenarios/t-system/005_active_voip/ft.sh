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

DURATION=60
STARTTIME=120
MIDDURATION=120
ENDDURATION=120

MAXNODES=38

#growing_measurement.sh  min_no_of_clients max_no_of_clients step sleeptime startdelay staydelay enddelay

#ORG stuff (SIZE 70, INTERVAL 12, MAXSEQ 500000, BURST 4, ACTIVE true)

if [ -f foreign_node.click.save ]; then
  mv foreign_node.click.save foreign_node.click
fi

mv foreign_node.click foreign_node.click.save

if [ "x" = "y" ]; then
echo "No foreign traffic"
./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 000-noft

echo "Foreign traffic 20% with cca"

#cat foreign_node.click.save | sed "s#INTERVAL 120#INTERVAL 65#g" | sed "s#BURST 1#BURST 1#g" > foreign_node.click
#cat foreign_node.click.save | sed "s#INTERVAL 120#INTERVAL 19#g" | sed "s#BURST 1#BURST 4#g" > foreign_node.click
cat foreign_node.click.save | sed "s#SIZE 70#SIZE 28#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-20ft_cca

echo "Foreign traffic 20% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-20ft_nocca




echo "Foreign traffic 30% with cca"

#cat foreign_node.click.save | sed "s#INTERVAL 120#INTERVAL 42#g" | sed "s#BURST 1#BURST 1#g" > foreign_node.click
#cat foreign_node.click.save | sed "s#INTERVAL 120#INTERVAL 12#g" | sed "s#BURST 1#BURST 4#g" > foreign_node.click
cat foreign_node.click.save | sed "s#SIZE 70#SIZE 148#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-30ft_cca

echo "Foreign traffic 30% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-30ft_nocca




echo "Foreign traffic 40% with cca"

#cat foreign_node.click.save | sed "s#INTERVAL 120#INTERVAL 32#g" | sed "s#BURST 1#BURST 1#g" > foreign_node.click
#cat foreign_node.click.save | sed "s#INTERVAL 120#INTERVAL 14#g" | sed "s#BURST 1#BURST 6#g" > foreign_node.click
cat foreign_node.click.save | sed "s#SIZE 70#SIZE 278#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-40ft_cca

echo "Foreign traffic 40% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-40ft_nocca




echo "Foreign traffic 50% with cca"

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 408#g" | sed "s#INTERVAL 12#INTERVAL 10#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-50ft_cca

echo "Foreign traffic 50% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-50ft_nocca


echo "Foreign traffic 10% with cca"

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 8#g" | sed "s#INTERVAL 12#INTERVAL 14#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
FT=yes CCA=1 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-10ft_cca

fi

cat foreign_node.click.save | sed "s#SIZE 70#SIZE 8#g" | sed "s#INTERVAL 12#INTERVAL 14#g" | sed "s#BURST 4#BURST 1#g" > foreign_node.click
echo "Foreign traffic 10% with nocca"
FT=yes CCA=0 ./growing_measurement.sh 1 $MAXNODES 1 $DURATION $STARTTIME $MIDDURATION $ENDDURATION

mv 1 001-10ft_nocca


echo "restore org"

rm -f foreign_node.click
mv foreign_node.click.save foreign_node.click

exit 0