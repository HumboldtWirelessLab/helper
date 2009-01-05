BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(1400, 12, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
// -> EtherEncap(0x8088, my_wlan, 00:0a:03:04:05:06)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> SetTXPower(16)
 -> rrs :: RoundRobinSwitch()
 -> BRN2SetChannel(CHANNEL 6)
 -> Ath2Encap(ATHENCAP true)
 -> wlan_out_queue :: NotifierQueue(1200);

//rrs[1]
// -> BRN2SetChannel(CHANNEL 11)
// -> Ath2Encap(ATHENCAP true)
// -> wlan_out_queue;

wlan_out_queue
 -> Print("Raw",100)
 -> TORAWDEVICE;

Script(
  wait RUNTIME,
  stop
);
