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
  
Script(
  wait RUNTIME,
  stop
);
