BRNAddressInfo(my_wlan NODEDEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
//  -> WIFIDECAP
//  -> ethertee :: Tee()
//  -> ftx :: FilterTX()
//  -> ff :: FilterFailures()
//  -> fphy :: FilterPhyErr()
//  -> pw :: PrintWifi(TIMESTAMP true)
  -> Discard();
  
  rawtee[1]
  -> tdraw :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.raw.dump");
  
//  ethertee[1]
//  -> td :: ToDump("RESULTDIR/NODENAME.NODEDEVICE.dump")

Script(
  wait RUNTIME,
  stop
);
