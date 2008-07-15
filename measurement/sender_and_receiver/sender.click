AddressInfo(my_wlan DEVICE:eth);

BRN2PacketSource(1000, 100, 1000)
 -> SetTimestamp()
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(50);

BRN2PacketSource(1000, 100, 1000)
 -> SetTimestamp()
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(4)
 -> wlan_out_queue;

BRN2PacketSource(1000, 100, 1000)
 -> SetTimestamp()
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(11)
 -> wlan_out_queue;

BRN2PacketSource(1000, 100, 1000)
 -> SetTimestamp()
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(22)
 -> wlan_out_queue;
	  
wlan_out_queue
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
