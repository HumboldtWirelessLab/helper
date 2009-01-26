BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(50, 100, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, 00:0a:03:04:05:06)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(500);
	  
wlan_out_queue
-> SetTXPower(10)
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
