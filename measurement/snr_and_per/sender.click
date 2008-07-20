AddressInfo(my_wlan ath0:eth);

FromDevice(ath0) // , PROMISC true
  -> AthdescDecap()
  -> filter :: FilterTX();

filter[0]
  -> WifiDupeFilter()
  -> Discard;

filter[1]
  -> PrintWifi(TIMESTAMP true)
  -> Discard;

BRN2PacketSource(1000, 20, my_wlan, ff:ff:ff:ff:ff:ff)
  -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(24)                                                                                                                                                     
  -> wlan_out_queue :: NotifierQueue(50);

wlan_out_queue
  -> AthdescEncap()
  -> ToDevice(ath0);

ControlSocket("TCP", 1234 );

Script(
    wait 120,
    stop
);
