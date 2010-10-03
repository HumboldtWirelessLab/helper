BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(SIZE 100, INTERVAL 100, MAXSEQ 500000, BURST 1)
 -> rrs :: RoundRobinSwitch()
 -> EtherEncap(0x8088, 00:0c:0c:0c:0c:01, 06:0b:6b:09:f2:94 )
 -> wifienc :: WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(100)
 -> SetTXPower(16)
 -> TODEVICE(NODEDEVICE);

rrs[1]
 -> EtherEncap(0x8088, 00:0c:0c:0c:0c:02, 06:0b:6b:09:f2:94 )
 -> wifienc;
