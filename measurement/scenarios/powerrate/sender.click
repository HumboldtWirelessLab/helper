BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
-> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(1000, 2, 30000, 14, 2, 16)
 -> EtherEncap(0x8088, my_wlan , 06:0c:42:0c:74:0e )
 -> WifiEncap(0x00, 0:0:0:0:0:0)
 -> wlan_out_queue :: NotifierQueue(50);
	  
wlan_out_queue
-> SetTXRates(RATE0 108, RATE1 72, RATE2 22 RATE3 2,  TRIES0 2, TRIES1 2, TRIES0 2, TRIES0 3)
-> SetTXPower(16)
-> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
