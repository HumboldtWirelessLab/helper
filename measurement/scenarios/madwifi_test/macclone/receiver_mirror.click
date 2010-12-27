BRNAddressInfo(my_wlan NODEDEVICE:eth);

//AddressInfo(dst 10.0.0.1 06-0F-B5-0B-A8-92); //wgt76
AddressInfo(dst 10.0.0.1 06-0B-6B-09-F2-94); //sk111
//AddressInfo(dst 10.0.0.1 06-11-6B-61-CF-B6);
//AddressInfo(dst 10.0.0.1 06-0F-B5-97-34-E9)  //wgt52

FROMRAWDEVICE(NODEDEVICE)
  -> t::Tee()
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

  t[1]
  -> __WIFIDECAP__
  -> filter_tx :: FilterTX()
  -> WifiDecap()
  -> seq_clf :: Classifier( 12/8088, - )
  -> EtherMirror()
  -> wifienc :: WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> SetTXPower(15)
  -> __WIFIENCAP__
  -> wlan_out_queue :: NotifierQueue(100)
  -> TORAWDEVICE(NODEDEVICE);

BRN2PacketSource(SIZE 100, INTERVAL 100, MAXSEQ 500000, BURST 1, ACTIVE false)
  -> EtherEncap(0x8088, my_wlan, 06-0B-6B-09-ED-73)
  -> wifienc;

  seq_clf[1]
  -> Discard;

  filter_tx[1]
  -> Discard;
