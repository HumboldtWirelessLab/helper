BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(1000, 10, 1000, 14, 22, 16)
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
// -> Print("NODE: ", 200)
 -> SetTXRate(22)
 -> SetTXPower(15)
 -> wlan_out_queue :: NotifierQueue(5000);
	  
wlan_out_queue
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
