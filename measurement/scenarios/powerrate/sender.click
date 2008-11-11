BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(100, 250, 30000, 14, 2, 16)
// -> EtherEncap(0x8088, my_wlan , 06:0c:42:0c:74:0e )
// -> EtherEncap(0x8088, my_wlan , 06:0c:52:0c:74:0e )
// 00:0F:B5:97:32:59 00:0F:B5:97:35:8C
 -> EtherEncap(0x8088, my_wlan , 00:0F:B5:97:35:8C )
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> wlan_out_queue :: NotifierQueue(500);
	  
wlan_out_queue
-> SetTXRates(RATE0 108, RATE1 11, RATE2 4, RATE3 2, TRIES0 2, TRIES1 2, TRIES2 2, TRIES3 3)
//-> SetTXRate(108)
-> SetTXPower(6)
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
