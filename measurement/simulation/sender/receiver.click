AddressInfo(my_wlan eth0:eth);

FromSimDevice(eth0,4096)
 -> Strip(14)
// -> ToDump("/dev/shm/receiver.dump");
 -> BRN2PrintWifi()
 -> Discard;  

BRN2PacketSource(1000, 1000, my_wlan, ff:ff:ff:ff:ff:ff)
 -> SetTimestamp()
 -> EtherEncap(0x8086, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
 -> AddEtherNsclick()
 -> ToSimDevice(eth0);

Script(                                                                                                                                                                                                             
  wait 20,                                                                                                                                                                                                        
  stop                                                                                                                                                                                                            
);
