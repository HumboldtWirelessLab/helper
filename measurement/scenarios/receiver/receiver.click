BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
  -> Ath2Decap( ATHDECAP true )
  -> ftx :: FilterTX()
  -> ff :: FilterFailures()
  -> fphy :: FilterPhyErr()
  -> Print("Raw")
  -> pw :: PrintWifi(TIMESTAMP true)
  -> Discard();
  
  rawtee[1]
//  -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
    -> Idle;

Script(
  wait RUNTIME,
  stop
);
