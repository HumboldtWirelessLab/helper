AddressInfo(my_wlan NODEDEVICE:eth);

RatedSource(\<0800>, 10, 1000)
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> Print("NODENAME: ", 200)
 -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
-> Discard;

Script(
  wait RUNTIME,
  stop
);
