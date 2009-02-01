BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.in.dump");

BRN2PacketSource(1000, 100, 1000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan, 06:0C:42:0C:74:0E)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRates(RATE0 108, RATE1 22, RATE2 4, RATE3 2, TRIES0 3, TRIES1 2, TRIES2 2, TRIES3 2)
  -> cl::Classifier(6/060C420C85F4,-)
  -> wlan_out_queue :: NotifierQueue(500);
	  
BRN2PacketSource(1000, 100, 1000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan, 06-0C-42-0C-85-F4)
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRates(RATE0 108, RATE1 22, RATE2 4, RATE3 2, TRIES0 3, TRIES1 2, TRIES2 2, TRIES3 2)
  -> cl2::Classifier(6/060C420C740E,-)
  -> wlan_out_queue :: NotifierQueue(500);

cl2[1]->Discard;
	  
wlan_out_queue
  -> SetTXPower(1)
  -> WIFIENCAP
  -> rawouttee :: Tee()
  -> TORAWDEVICE;

rawouttee[1]
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.out.dump");

Script(
  wait RUNTIME,
  stop
);
