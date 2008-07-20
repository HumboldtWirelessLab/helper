AddressInfo(my_wlan DEVICE:eth);

BRN2PacketSource(1000, 100, 1000)
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> Print("NODE: ", 200)
 -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
