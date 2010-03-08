BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(1400, 10, 1000, 14, 2 ,16)
//-> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> EtherEncap(0x8088, my_wlan, 06:0B:6B:09:ED:73)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
// -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(1000);

//BRN2PacketSource(1000, 100, 1000, 14, 2 ,16)
// -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
// -> WifiEncap(0x00, 0:0:0:0:0:0)
// -> SetTXRate(4)
// -> wlan_out_queue;

//BRN2PacketSource(1000, 100, 1000, 14, 2 ,16)
// -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
// -> WifiEncap(0x00, 0:0:0:0:0:0)
// -> SetTXRate(11)
// -> wlan_out_queue;

//BRN2PacketSource(1000, 100, 1000, 14, 2 ,16)
// -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
// -> WifiEncap(0x00, 0:0:0:0:0:0)
// -> SetTXRate(22)
// -> wlan_out_queue;

				    


rt::AvailableRates(DEFAULT 2 4 11 12 18 22 24 36 48 72 96 108);
//"OFFSET", 0, cpUnsigned, &_offset,
//"RT", 0, cpElement, &_rtable,
//"THRESHOLD", 0, cpUnsigned, &_packet_size_threshold,
//"ALT_RATE", 0, cpBool, &_alt_rate,
//"ACTIVE", 0, cpBool, &_active,
//"PERIOD", 0, cpUnsigned, &_period,
								      
wlan_out_queue
-> mr::MadwifiRate(OFFSET 4, RT rt, THRESHOLD 0, ALT_RATE true, ACTIVE true, PERIOD 1000) 
-> SetTXPower(16)
//-> WIFIENCAP
//-> Print("Raw",100)
//-> TORAWDEVICE;
-> TODEVICE;

FROMDEVICE
  -> filter_tx :: FilterTX()
  -> Discard;      

 
filter_tx[1]
 -> [1]mr[1]
 -> Discard;


Script(
  wait RUNTIME,
  stop
);
