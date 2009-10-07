RatedSource("aaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbb", 30, 1000)
 -> EtherEncap(0x8088, 06:0B:6B:09:F2:94, ff:ff:ff:ff:ff:ff)
// -> EtherEncap(0x8088, 06:0B:6B:09:F2:94, 00:0a:03:04:05:06)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> SetTXPower(16)
 -> rrs :: RoundRobinSwitch()
 -> AthSetChannel(CHANNEL 6)
 -> Ath2Encap(ATHENCAP true)
 -> wlan_out_queue :: NotifierQueue(1200);

rrs[1]
 -> AthSetChannel(CHANNEL 11)
 -> Ath2Encap(ATHENCAP true)
 -> wlan_out_queue;

wlan_out_queue
// -> Print("Raw",100)
 -> TORAWDEVICE;

Script(
  wait RUNTIME,
  stop
);
