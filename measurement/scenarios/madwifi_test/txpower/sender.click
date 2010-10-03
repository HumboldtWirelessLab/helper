BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(SIZE 150, INTERVAL 50, MAXSEQ 500000, BURST 1)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> rrs :: RoundRobinSwitch()
 -> SetTXPower(15)
 -> __WIFIENCAP__
 -> wlan_out_queue :: NotifierQueue(100);

rrs[1]
 -> SetTXPower(1)
 -> __WIFIENCAP__
 -> wlan_out_queue;

wlan_out_queue
 -> TORAWDEVICE(NODEDEVICE);
