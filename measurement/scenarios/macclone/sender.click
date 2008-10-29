BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(1000, 100, 1000, 14, 2, 16)
// -> EtherEncap(0x8088, 00:0c:42:0d:85:f1 , ff:ff:ff:ff:ff:ff)
// -> EtherEncap(0x8088, my_wlan , 06:0c:42:0c:74:0e )
 -> EtherEncap(0x8088, 00:0c:42:0d:85:f1 , 06:0c:42:0c:74:0e )
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> SetTXRate(2)
 -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
-> SetTXPower(7)
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
