BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(SIZE 150, INTERVAL 50, MAXSEQ 500000, BURST 1)
 -> EtherEncap(0x8088, my_wlan, 06:0b:6b:09:f2:94)
// -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
// -> WMMWifiEncap(0x00, 0:0:0:0:0:0, 57, 16)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> SetTXPower(15)
 -> wlan_out_queue :: NotifierQueue(100);

wlan_out_queue
-> __WIFIENCAP__
-> AthSetFlags(CTS 1, RTSCTS 0, ANTXM 0, NOACK 0)
-> TORAWDEVICE(NODEDEVICE)
