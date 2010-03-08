BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");

BRN2PacketSource(1000, 25, 1000, 14, 2 ,16)
//  -> EtherEncap(0x8088, my_wlan, FF:FF:FF:FF:FF:FF)
  -> EtherEncap(0x8088, my_wlan, 06:0B:6B:09:F2:93) //94
  -> WifiEncap(0x00, 0:0:0:0:0:0)
//  -> SetTXRate(4)
  -> SetTXRates(RATE0 22, RATE1 11, RATE2 4, RATE3 2, TRIES0 1, TRIES1 1, TRIES2 1, TRIES3 1)
  -> wlan_out::SetTXPower(15);
	  
BRN2PacketSource(100, 3000, 1000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan, FF:FF:FF:FF:FF:FF)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> wlan_out;

wlan_out
  -> NotifierQueue(500)
  -> WIFIENCAPTMPL
//  -> AthSetFlags(CTS 1)
  -> TORAWDEVICE;

Script(
  wait RUNTIME,
  stop
);
