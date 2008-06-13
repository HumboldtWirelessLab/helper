AddressInfo(my_wlan ath0:eth);

BRN2PacketSource(1000, 100, 0)
 -> SetTimestamp()
 -> EtherEncap(0x8087, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(100);
	  
wlan_out_queue
-> AthdescEncap()
-> ToDevice(ath0);
