BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(1000, 50, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
// -> EtherEncap(0x8088, my_wlan, 00:0a:03:04:05:06)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(108)
 -> wlan_out_queue :: NotifierQueue(500);

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
	  
wlan_out_queue
-> SetTXPower(1)
//-> WIFIENCAP
//-> Print("Raw",100)
//-> TORAWDEVICE;
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
