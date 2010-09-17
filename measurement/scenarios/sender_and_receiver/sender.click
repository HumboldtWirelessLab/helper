BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(VAR_PSIZE, VAR_RATE, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(500);
	  
wlan_out_queue
-> SetTXPower(16)
-> TODEVICE;
