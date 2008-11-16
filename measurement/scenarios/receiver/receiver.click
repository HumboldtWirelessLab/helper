BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
  -> Ath2Decap( ATHDECAP true )
  -> ftx :: FilterTX()
  -> ff :: FilterFailures()
  -> fphy :: FilterPhyErr()
//  -> pw :: PrintWifi(TIMESTAMP true)
  -> Discard();
  
  rawtee[1]
  -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
  
Script(
  wait RUNTIME,
  stop
);
