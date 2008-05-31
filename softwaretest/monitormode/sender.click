AddressInfo(my_wlan ath0:eth);

FromDevice(ath0)
  -> AthdescDecap()
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> Discard;

filter[1]
  -> PrintWifi(TIMESTAMP true)
  -> Discard;

BRN2PacketSource(1000, 100,my_wlan, ff:ff:ff:ff:ff:ff)
  -> SetTimestamp()
  -> EtherEncap(0x8086, my_wlan, ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(22)                                                                                                                                                     
  -> wlan_out_queue :: NotifierQueue(50);

wlan_out_queue
  -> AthdescEncap()
  -> ToDevice(ath0);

ControlSocket("TCP", 1234 );

Script(
    wait 95,
    stop
);
