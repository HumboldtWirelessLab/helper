AddressInfo(my_wlan DEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
  -> AthdescDecap()
  -> ftx :: FilterTX()
  -> ff :: FilterFailures()
  -> fphy :: FilterPhyErr()
  -> pw :: PrintWifi(TIMESTAMP true)
  -> Discard();
  
  rawtee[1]
  -> td :: ToDump("RESULTDIR/NODE.DEVICE.dump");
  Idle()
  -> sc :: BRN2SetChannel(ath0,false)
  -> Discard;
  
Script(
  wait 20,
  write sc.channel 1,
  wait RUNTIME,
  stop
);
