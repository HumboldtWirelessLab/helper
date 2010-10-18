BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE(NODEDEVICE)
  -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.dump");

BRN2PacketSource(SIZE 1450, INTERVAL 25, MAXSEQ 500000, BURST 1)
  -> EtherEncap(0x8088, my_wlan,  FF:FF:FF:FF:FF:FF )
  -> WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> wlan_out::SetTXPower(15);

wlan_out
  -> __WIFIENCAP__
  -> rawouttee :: Tee()
  -> NotifierQueue(500)
  -> outct::Counter()
  -> TORAWDEVICE(NODEDEVICE);

rawouttee[1]
  -> TODUMP("RESULTDIR/NODENAME.NODEDEVICE.out.dump");

