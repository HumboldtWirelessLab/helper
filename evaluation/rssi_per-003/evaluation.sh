#!/bin/sh

for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    cat $i\_sender.log |   grep "Mb" | sed -e "s/cntl.* EXTRA: 8087/cntl 44 EXTRA: 8085/g" -e "s/: / /g" -e "s#/ [0-9]* \| # #g" -e "s#Mb[ ]*+# #g" -e "s#[ ]*|[ ]*# #g" -e "s#data.*EXTRA#0#g" -e "s#data.*s#0#g" -e "s#mgmt.*EXTRA#1#g" -e "s#cntl.*EXTRA#2#g" | awk '{print $1" "$2" "$3" "$4" "$5" "gsub("80870000","muell",$6)" "strtonum("0x"$7)";"}' | sed -e "s\,\.\g" > $i\_sender.dat
    cat $i\_receiver.log | grep "Mb" | grep -v "^\." | grep -v "\.\.\.\.\." | sed -e "s/cntl.* EXTRA: 8087/cntl 44 EXTRA: 8085/g" -e "s/: / /g" -e "s#/ [0-9]* \| # #g" -e "s#Mb[ ]*+# #g" -e "s#[ ]*|[ ]*# #g" -e "s#data.*EXTRA#0#g" -e "s#data.*s#0#g" -e "s#mgmt.*EXTRA#1#g" -e "s#cntl.*EXTRA#2#g" | awk '{print $1" "$2" "$3" "$4" "$5" "gsub("80870000","muell",$6)" "strtonum("0x"$7)";"}' | sed -e "s\,\.\g" -e "s#mgmt#1#g" > $i\_receiver.dat
done

exit 0