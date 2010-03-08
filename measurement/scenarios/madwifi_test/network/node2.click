BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");

BRN2PacketSource(500, 2500, 1000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan, FF:FF:FF:FF:FF:FF)
//  -> EtherEncap(0x8088, my_wlan, 06:0B:6B:04:F2:94)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
//  -> SetTXRates(RATE0 108, RATE1 22, RATE2 4, RATE3 2, TRIES0 3, TRIES1 2, TRIES2 2, TRIES3 2)
  -> wlan_out::SetTXPower(15);
	  
BRN2PacketSource(100, 5000, 1000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan, FF:FF:FF:FF:FF:FF)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> wlan_out;

wlan_out
  -> NotifierQueue(500)
  -> WIFIENCAPTMPL
//  -> AthSetFlags(CTS 1)
  -> TORAWDEVICE;
	
//  -> TODEVICE;

Script(
  wait RUNTIME,
  stop
);
