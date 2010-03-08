BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");

BRN2PacketSource(300, 1500, 1000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan, FF:FF:FF:FF:FF:FF)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> SetTXPower(15)
  -> NotifierQueue(500)
  -> WIFIENCAPTMPL
//  -> AthSetFlags(CTS 1)
  -> TORAWDEVICE;
	
 // -> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
