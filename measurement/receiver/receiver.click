AddressInfo(my_wlan DEVICE:eth);

FROMRAWDEVICE
  -> rawtee :: Tee()
<<<<<<< HEAD:measurement/receiver/receiver.click
=======
  -> AthdescDecap()
>>>>>>> dc69b9d808723132f434925e6192f0650f849352:measurement/receiver/receiver.click
  -> ftx :: FilterTX()
  -> ff :: FilterFailures()
  -> fphy :: FilterPhyErr()
  -> pw :: PrintWifi(TIMESTAMP true)
  -> Discard();
<<<<<<< HEAD:measurement/receiver/receiver.click
  
  rawtee[1]
  -> td :: ToDump("RESULTDIR/DEVICE.NODE.dump");
  
//ftx[1]
//-> Print("TX")
//-> [0]ff;

//ff[1]
//-> Discard();
//-> Print("Failure")
//-> [0]fphy;
=======
>>>>>>> dc69b9d808723132f434925e6192f0650f849352:measurement/receiver/receiver.click

rawtee[1]
->td :: ToDump("/home/all/trash/measurement/lab/helper/measurement/receiver/NODE.DEVICE.dump");

Script(
  wait RUNTIME,
  stop
);
