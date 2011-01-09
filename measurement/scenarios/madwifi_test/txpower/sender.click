BRNAddressInfo(my_wlan NODEDEVICE:eth);

BRN2PacketSource(SIZE 150, INTERVAL 50, MAXSEQ 500000, BURST 1, ACTIVE true)
 -> EtherEncap(0x8088, my_wlan, 06-0B-6B-09-F2-94)
// -> EtherEncap(0x8088, my_wlan, ff:ff:ff:ff:ff:ff)
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(RATE 12)
 -> rrs :: RoundRobinSwitch()
 -> SetTXPower(15)
 -> __WIFIENCAP__
 -> wlan_out_queue :: NotifierQueue(100);

rrs[1]
 -> SetTXPower(5)
 -> __WIFIENCAP__
 -> wlan_out_queue;

wlan_out_queue
 -> TORAWDEVICE(NODEDEVICE);

FROMRAWDEVICE(NODEDEVICE)
  -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
