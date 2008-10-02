FromDump("WORKDIR/NODE.DEVICE.dump")
 -> AthdescDecap()
 -> ftx :: FilterTX()
 -> ff :: FilterFailures()
 -> fphy :: FilterPhyErr()
 -> pw :: PrintWifi(TIMESTAMP true)
 -> Discard;
  
ftx[1]
-> Print("TX: ")
-> [0]pw;

ff[1]
-> Print("Failure: ")
-> [0]pw;

fphy[1]
-> Print("Phy: ")
-> [0]pw;

Script(
  wait RUNTIME,
  stop
);
