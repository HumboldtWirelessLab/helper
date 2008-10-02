#!/bin/sh

killall click

sleep 1
wlanconfig ath1 destroy
sleep 1
wlanconfig ath0 destroy
sleep 1

./device.sh start /home/madwifi/etc/wifi/seismo.ath0
./device.sh start /home/madwifi/etc/wifi/seismo.ath1

while true; do

for i in 2 4 6 8 10 12 14 16; do

iwconfig ath0 txpower $i
iwconfig ath1 txpower $i

cat ../config/sender.seismo.ath0.click.dyn | sed -e "s#SETPOWER#$i#g" > ../config/sender.seismo.ath0.click
cat ../config/sender.seismo.ath1.click.dyn | sed -e "s#SETPOWER#$i#g" > ../config/sender.seismo.ath1.click

./click-align ../config/sender.seismo.ath0.click | ./click &
./click-align ../config/sender.seismo.ath1.click | ./click &

sleep 40;

killall click

done

done

