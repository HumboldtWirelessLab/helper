BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(SIZE 1700, INTERVAL 100, MAXSEQ 500000, BURST 1, ACTIVE true)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> SetTXPower(1)
 -> rrs :: RoundRobinSwitch()
 -> BRN2SetChannel(CHANNEL 6)
 -> wencap::__WIFIENCAP__
 -> wlan_out_queue :: NotifierQueue(100);

rrs[1]
 -> BRN2SetChannel(CHANNEL 11)
 -> wencap;

wlan_out_queue
 -> TORAWDEVICE(NODEDEVICE);
