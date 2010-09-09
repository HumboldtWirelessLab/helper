BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");
//  -> TODUMP("/tmp/extra/test/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(SIZE 1400, INTERVAL 15, MAXSEQ 500000, BURST 72)
//BRN2PacketSource(SIZE 1300, INTERVAL 25, MAXSEQ 500000, BURST VAR_RATE)
  -> EtherEncap(0x8088, my_wlan,  FF:FF:FF:FF:FF:FF )
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(72)
//  -> SetTXRate(VAR_RATE)
//-> SetTXRates(RATE0 108, RATE1 22, RATE2 4, RATE3 2, TRIES0 3, TRIES1 2, TRIES2 2, TRIES3 2)
  -> wlan_out::SetTXPower(15);

wlan_out
  -> WIFIENCAPTMPL
  -> rawouttee :: Tee()
  -> NotifierQueue(500)
  -> outct::Counter()
  -> TORAWDEVICE;

rawouttee[1]
//  -> TODUMP("/tmp/extra/test/NODENAME.NODEDEVICE.out.dump");
  -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

Script(
  wait 55,
  read outct.count
);

Script(
  wait RUNTIME,
  stop
);
