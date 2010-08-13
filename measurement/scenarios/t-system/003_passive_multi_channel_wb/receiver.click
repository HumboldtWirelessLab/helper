BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
//  -> rawtee :: Tee()
//  -> Ath2Decap( ATHDECAP true )
//  -> ftx :: FilterTX()
//  -> ff :: FilterFailures()
//  -> fphy :: FilterPhyErr()
//  -> Print("Raw")
//  -> pw :: PrintWifi(TIMESTAMP true)
//  -> Discard();
  
//  rawtee[1]
    -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump");
//    -> td :: ToDump("/tmp/extra/mess_2/NODENAME.NODEDEVICE.dump"/*, SNAPLEN 150*/);
//  -> Idle;

//  Idle
//  -> Socket(UDP, 0.0.0.0, 60000)
//  -> Print("Sync",TIMESTAMP true)
//  -> td;

Script(
  wait RUNTIME,
  stop
);
