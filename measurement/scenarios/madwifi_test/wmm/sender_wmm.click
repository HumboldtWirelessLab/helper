BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(1200, 15, 1000, 14, 2 ,16)
// -> EtherEncap(0x8088, my_wlan, 06:0C:42:0C:74:0E)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
// -> WMMWifiEncap(0x00, 0:0:0:0:0:0, 57, 16)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(1000);
	  
wlan_out_queue
//-> SetTXPower(15)
//-> TODEVICE;
-> WIFIENCAP
//-> AthSetFlags(CTS 0, RTSCTS 0, ANTXM 0, NOACK 0)
-> TORAWDEVICE

Script(
  wait RUNTIME,
  stop
);
