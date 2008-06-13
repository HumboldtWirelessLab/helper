AddressInfo(my_wlan DEVICE:eth);

FROMDEVICE
 -> BRN2PrintWifi()
 -> Discard;  

BRN2PacketSource(1000, 1000, 0)
 -> SetTimestamp()
 -> EtherEncap(0x8086, my_wlan, ff:ff:ff:ff:ff:ff)
 -> BRN2Networkcoding()
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
