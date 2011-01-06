BRNAddressInfo(my_wlan NODEDEVICE:eth);

//AddressInfo(dst 10.0.0.1 06-0F-B5-0B-A8-92); //wgt76
AddressInfo(dst 10.0.0.1 06-0B-6B-09-F2-94); //sk111
//AddressInfo(dst 10.0.0.1 06-11-6B-61-CF-B6);
//AddressInfo(dst 10.0.0.1 06-0F-B5-97-34-E9)  //wgt52

wireless::BRN2Device(DEVICENAME "NODEDEVICE", ETHERADDRESS my_wlan, DEVICETYPE "WIRELESS");

FROMRAWDEVICE(NODEDEVICE)
  -> t::Tee()
  -> ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");

  t[1]
  -> dev_decap::__WIFIDECAP__
  -> filter_tx :: FilterTX()
  -> WifiDecap()
  -> seq_clf :: Classifier( 12/8088, - )
  -> EtherMirror()
  -> Discard;
  Idle
  -> wifienc :: WifiEncap(0x00, 0:0:0:0:0:0)
  -> SetTXRate(2)
  -> SetTXPower(15)
  -> __WIFIENCAP__
  -> wlan_out_queue :: NotifierQueue(100)
  -> __WIFIENCAP__
  -> [1]op_prio_s::PrioSched()
  -> tor::TORAWDEVICE(NODEDEVICE);

  dev_decap[2]
  -> ath_op::Ath2Operation(DEVICE wireless, READCONFIG true, DEBUG 2)
  -> ath_op_q::NotifierQueue(10)
  -> op_prio_s;

dev_decap[1]
  -> rawwifidev_too_small_cnt::Counter
  -> Discard;


BRN2PacketSource(SIZE 100, INTERVAL 100, MAXSEQ 500000, BURST 1, ACTIVE false)
  -> EtherEncap(0x8088, my_wlan, 06-0B-6B-09-ED-73)
  -> wifienc;

  seq_clf[1]
  -> Discard;

  filter_tx[1]
  -> Discard;
