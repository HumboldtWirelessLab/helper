BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(50, 100, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, 06:0C:42:0C:74:0E)
// -> WMMWifiEncap(0x00, 0:0:0:0:0:0, 57, 16)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(108)
 -> wlan_out_queue :: NotifierQueue(500);
	  
wlan_out_queue
-> SetTXPower(10)
//-> TODEVICE;
-> WIFIENCAP
-> AthSetFlags(CTS 0, RTSCTS 0, ANTXM 4)
-> TORAWDEVICE

Script(
  wait RUNTIME,
  stop
);
