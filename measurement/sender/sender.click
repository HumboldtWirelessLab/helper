AddressInfo(my_wlan DEVICE:eth);

FROMDEVICE
//-> ToDump("/dev/shm/receiver.dump");
 -> BRN2PrintWifi()
 -> Discard;  

BRN2PacketSource(1000, 100, 1000)
 -> SetTimestamp()
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> Print("pa: ", 200)
 -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
