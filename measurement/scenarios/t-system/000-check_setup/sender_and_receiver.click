BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
  -> ToDump("/tmp/extra/test/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(1000, 14, 500000, 14, 2 ,16)
  -> EtherEncap(0x8088, my_wlan,  FF:FF:FF:FF:FF:FF )
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
//  -> SetTXRates(RATE0 108, RATE1 22, RATE2 4, RATE3 2, TRIES0 3, TRIES1 2, TRIES2 2, TRIES3 2)
  -> wlan_out::SetTXPower(15);
	  
//BRN2PacketSource(1000, 100, 1000, 14, 2 ,16)
//  -> EtherEncap(0x8088, my_wlan, 06-0C-42-0C-85-F4)
//  -> cl::Classifier(6/060C420C740E,-)
//  -> WifiEncap(0x00, 0:0:0:0:0:0)
//  -> SetTXRates(RATE0 108, RATE1 22, RATE2 4, RATE3 2, TRIES0 3, TRIES1 2, TRIES2 2, TRIES3 2)
//  -> wlan_out;


//cl[1] -> Discard;
//cl2[1] -> Discard;
	  
wlan_out
  -> WIFIENCAPTMPL
  -> rawouttee :: Tee()
  -> NotifierQueue(500)
  -> TORAWDEVICE;

rawouttee[1]
  -> ToDump("/tmp/extra/test/NODENAME.NODEDEVICE.out.dump");
//  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

Script(
  wait RUNTIME,
  stop
);
