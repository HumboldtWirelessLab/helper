BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
  -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");

//Interval of 10 results in 100Hz. so burst can be used as multiply factor for rate
ps::BRN2PacketSource(SIZE 593, INTERVAL 10, MAXSEQ 500000, BURST 1, ACTIVE true)
//ps::BRN2PacketSource(SIZE 1400, INTERVAL 14, MAXSEQ 500000, BURST 6, ACTIVE true)
//ps::BRN2PacketSource(SIZE 1400, INTERVAL 10, MAXSEQ 500000, BURST VAR_BURST, ACTIVE true)
  -> EtherEncap(0x8089, my_wlan,  ff:ff:ff:ff:ff:ff )
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(RATE 2, TRIES 1)
  -> wlan_out::SetTXPower(15);

wlan_out
  -> __WIFIENCAP__
  -> SetTimestamp()
  -> rawouttee :: Tee()
  -> fdq :: FrontDropQueue(100)
  -> TORAWDEVICE(NODEDEVICE);

rawouttee[1]
  -> tdout :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

fdq[1]
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.drop.dump");

SYNC
  -> tdout;
