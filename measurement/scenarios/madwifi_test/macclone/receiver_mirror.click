BRNAddressInfo(my_wlan NODEDEVICE:eth);

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

  seq_clf[1]
  -> Discard;

  filter_tx[1]
  -> Discard;
