BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(1000, 2, 30000, 14, 2, 16)
 -> rrs :: RoundRobinSwitch()
// -> Print("Foo")
 -> EtherEncap(0x8088, 00:0c:42:0d:85:f1 , 06:0c:42:0c:74:0e )
 
 -> wifienc :: WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(22)
 -> wlan_out_queue :: NotifierQueue(100)
 -> SetTXPower(16)
 -> TODEVICE;

 rrs[1]
// -> Print("Bar")
 -> EtherEncap(0x8088, 00:0c:52:1d:95:f2 , 06:0c:42:0c:74:0e )
 -> wifienc;

Script(
  wait RUNTIME,
  stop
);
