BRNAddressInfo(my_wlan NODEDEVICE:eth);                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                       
BRN2PacketSource(100, 50, 1000, 14, 2 ,16)
 -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> rrs :: RoundRobinSwitch()
 -> SetTXPower(16)
 -> Ath2Encap(ATHENCAP true)
 -> wlan_out_queue :: NotifierQueue(1200);

rrs[1]
 -> SetTXPower(1)
 -> Ath2Encap(ATHENCAP true)
 -> wlan_out_queue;

wlan_out_queue
 -> TORAWDEVICE;

Script(
  wait RUNTIME,
  stop
);
