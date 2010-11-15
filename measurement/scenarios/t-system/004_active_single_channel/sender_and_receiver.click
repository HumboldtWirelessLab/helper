BRNAddressInfo(my_wlan NODEDEVICE:eth);

//FROMRAWDEVICE(NODEDEVICE)
//  -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(SIZE 100/*1450*/, INTERVAL 5, MAXSEQ 500000, BURST 100)
//BRN2PacketSource(SIZE 1300, INTERVAL 30, MAXSEQ 500000, BURST VAR_RATE)
//  -> EtherEncap(0x8088, 00:04:06:05:03:03,  FF:FF:FF:FF:FF:FF )
//  -> EtherEncap(0x8088, my_wlan, 00:04:06:05:03:03 )
  -> EtherEncap(0x8088, my_wlan,  FF:FF:FF:FF:FF:FF )
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(108)
//-> SetTXRate(VAR_RATE)
//-> SetTXRates(RATE0 108, RATE1 22, RATE2 4, RATE3 2, TRIES0 3, TRIES1 2, TRIES2 2, TRIES3 2)
  -> wlan_out::SetTXPower(15);

wlan_out
  -> __WIFIENCAP__
//  -> rawouttee :: Tee()
  -> NotifierQueue(500)
  -> outct::Counter()
  -> TORAWDEVICE(NODEDEVICE);

//rawouttee[1]
//  -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

Script(
  wait 55,
  read outct.count
);
