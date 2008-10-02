FromDump("WORKDIR/NODE.DEVICE.dump")
  -> AthdescDecap()
//-> ftx :: FilterTX()
//-> ff :: FilterFailures()
//-> rate_clf :: Classifier(8/00%70)
 -> fphy :: FilterPhyErr()
 -> pw :: Print("Receive: ")
//-> pw :: PrintWifi(TIMESTAMP true)
  ->Discard;
  
//ftx[1]
//-> Print("TX: ")
//-> [0]ff;

//ff[1]
//-> Print("Failure: ")
//-> [0]fphy;

fphy[1]
-> Print("Phy: ")
-> [0]pw;

Script(
  wait RUNTIME,
  stop
);
