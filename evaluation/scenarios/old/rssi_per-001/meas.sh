#!/bin/sh

rm -f ./sendpack.dat

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    NUMOFPAK=`cat 3500_out_sen_$i.log | grep "^1432" | wc -l`
    echo "$i $NUMOFPAK" >> ./sendpack.dat
    rm -f ./snr_$i.dat
    cat 3500_out_$i.log | grep --line-buffered "^1432" | cut -d + -f2 | cut -d / -f1 > ./snr_$i.dat  
done

exit 0