BRNAddressInfo(my_wlan NODEDEVICE:eth);
//AddressInfo(dst 10.0.0.1 06-0F-B5-0B-A8-92); //wgt76
AddressInfo(dst 10.0.0.1 06-0B-6B-09-F2-94); //sk111
//AddressInfo(dst 10.0.0.1 06-11-6B-61-CF-B6);
//AddressInfo(dst 10.0.0.1 06-0F-B5-97-34-E9)  //wgt52


FROMRAWDEVICE(NODEDEVICE)
-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(SIZE 100, INTERVAL 100, MAXSEQ 500000, BURST 1)
 -> rrs :: RoundRobinSwitch()
 -> EtherEncap(0x8088, 00:0c:0c:0c:0c:03, dst)
 -> wifienc :: WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(100)
 -> SetTXPower(15)
 -> Print("Out")
 -> TODEVICE(NODEDEVICE);

rrs[1]
 -> EtherEncap(0x8088, 00:0c:0c:0c:0c:04, dst)
 -> wifienc;
