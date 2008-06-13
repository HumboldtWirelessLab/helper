AddressInfo(my_wlan DEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
  -> ftx :: FilterTX()
  -> ff :: FilterFailures()
  -> fphy :: FilterPhyErr()
  -> AthdescDecap()
  -> pw :: PrintWifi(TIMESTAMP true)
  -> Discard();
  
  rawtee[1]
  -> td :: ToDump("RESULTDIR/DEVICE.NODE.dump");
  
//ftx[1]
//-> Print("TX")
//-> [0]ff;

//ff[1]
//-> Discard();
//-> Print("Failure")
//-> [0]fphy;

//fphy[1]
//-> Discard();
//-> Print("Phy")
//-> [0]pw;

Script(
  wait RUNTIME,
  stop
);
