AddressInfo(my_wlan ath0:eth);

FromDevice(ath0)
  -> AthdescDecap()
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> PrintWifi(TIMESTAMP true)
  -> Discard;

BRN2PacketSource(800, 1000)
  -> SetTimestamp()
  -> EtherEncap(0x8086, my_wlan, ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(22)                                                                                                                                                     
  -> wlan_out_queue :: NotifierQueue(50);

wlan_out_queue
  -> AthdescEncap()
  -> ToDevice(ath0);

filter[1]
-> PrintWifi("Feed:")
-> Discard;

ControlSocket("TCP", 1234 );

Script(
    wait 5,
    stop
);
